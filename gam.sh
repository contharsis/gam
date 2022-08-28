# GAM support - automatic login in github account in remote repository
cd(){
	builtin cd "$1"

	if [ "$2" != 'noextract' ]; then
		gam es default
	fi
}

# GAM - Github Account Manager - Put everything in an environment loader (e.g. ~/.bashrc) then reload it (e.g. source ~/.bashrc)

# Commands
# gam - Main command, used to access the others, write it before them (e.g. gam init, gam add and so on) (Use it on its own to show this text)
# help - Show this text
# init - Clear the config and initialize it
# add - Add an account
# rm - Remove an account - 1 Argument - Account username
# log - Log into an account - 1 Argument - Account username
# logo - Log out of currently logged in account
# ls - List only usernames of registered accounts
# lsaccs - List all information about the registered accounts 
# cu - Tell the currently logged account and its username
# cc - Change configs - 2 Arguments - Config option ; Config parameter
# ed - Manually edit configuration files (Not reccomended) - 1 Argument - config file name
# edf - List config file names
# sd - Set seed in current local repository (Has to be in current directory)
# es - Extract seed from current local repository (Has to be in current directory)

# Automatic login is enabled by default. When entering a seeded folder, the user will automatically
# be logged as the account seeded. To disable this use 'gam cc <config> <parameter>' and set it to false

gam(){
	local srcpath
	local accountsfilename
	local configfilename
	local accountspath
	local configpath
	local seedfilename
	local cmd
	
	srcpath="/home/$(whoami)/.gamconfig"
 	accountsfilename='accounts.txt'
	configfilename='config.txt'
 	accountspath="${srcpath}/${accountsfilename}"
 	configpath="${srcpath}/${configfilename}"
	seedfilename='accountseed.txt'	
	cmd="$1"
	
	if [ "$cmd" = 'help' ] || [ "$cmd" = '' ]; then
		cat <<-EOF
			GAM - Github Account Manager - Put everything in an environment loader (e.g. ~/.bashrc) then reload it (e.g. source ~/.bashrc)

			Commands:
			gam - Main command, used to access the others, write it before them (e.g. gam init, gam add and so on)
			init - Clear the config and initialize it
			add - Add an account
			rm - Remove an account - 1 Argument - Account username
			log - Log into an account - 1 Argument - Account username
			logo - Log out of currently logged in account
			ls - List only usernames of registered accounts
			lsaccs - List all information about the registered accounts
			cu - Tell the currently logged account and its username
			cc - Change configs - 2 Arguments - Config option ; Config parameter
			ed - Manually edit configuration files (Not reccomended) - 1 Argument - config file name
			edf - List config file names
			sd - Set seed in current local repository (Has to be in current directory)
			es - Extract seed from current local repository (Has to be in current directory)
			
			Config:
			Automatic login is enabled by default. When entering a seeded folder, the user will automatically
			be logged as the account seeded. To disable this use 'gam cc <config> <parameter>' and set it to false
		EOF

		return 0
	fi

	if  (! [ -d "$srcpath" ] || ! [ -f "$accountspath" ] || ! [ -f "$configpath" ]) && [ "$cmd" != 'init' ]; then
		echo "Error: Some initialization files don't exist, use 'gam init' to create it"
		return 0
	fi

	if [ "$cmd" = 'ch' ]; then
		local type
		local message
		local default_choice
		local result
		
		result="$2"
		type="$3"
		
		case "$type" in
			'1') message='Proceed with overwriting them? (THIS WILL DELETE THEM PERMANENTLY) (y/n, Default is n): ' ; default_choice='n' ;;
			
			'2') message="Add account seed '${4}' to .gitignore? (HIGHLY RECOMMENDED) (y/n, Default is y): " ; default_choice='y' ;;	
			
			'3') message="Proceed with creating '.gitignore' and add '${4}' to it? (y/n, Default is y): " ; default_choice='y' ;;

			'4') message="Proceed with overwriting it? (THIS WILL REPLACE IT WITH THE ACCOUNT WITH USERNAME '${4}') (y/n, Default is n): " ; default_choice='n' ;;
		esac

		local user_choice
		
		while true; do
			printf "$message" ; IFS= read -r user_choice
			
			if [ "$user_choice" = '' ]; then
				user_choice="$default_choice"
			fi

			if [ "$user_choice" = 'y' ] || [ "$user_choice" = 'n' ]; then
				break
			fi
		done

		eval $result="'$user_choice'"
	fi

	if [ "$cmd" = 'init' ]; then
		if ! [ -d "$srcpath" ]; then
			mkdir "$srcpath"
			touch "$accountspath"
			touch "$configpath"
			
			echo "[DON'T EDIT THIS FILE MANUALLY, ONLY USING 'gam add' or 'gam rm <username>']" > "$accountspath"
			echo '' >> "$accountspath"
			
			echo "[DON'T EDIT THIS FILE MANUALLY, ONLY USING 'gam cc <config> <paramater>']" > "$configpath"
			echo '' >> "$configpath"
			echo 'autologin=true' >> "$configpath"

			echo "From GAM - Github Account Manager"
			echo "Created and initialized '${accountsfilename}' and '${configfilename}' in folder '${srcpath}'"
		else
			if ! [ -f "$accountspath" ]; then
				touch "$accountspath"
				echo "[DON'T EDIT THIS FILE MANUALLY, ONLY USING 'gam add' or 'gam rm <username>']" > "$accountspath"
				echo '' >> "$accountspath"
				
				echo "Created and initialized '${accountsfilename}' in '${srcpath}'"
			else
				if [ "$2" = 'default' ]; then
					return 0
				fi

				echo "WARNING: Found '${accountsfilename}' in '${srcpath}' with content:"
				echo ''
				cat "$accountspath"
				echo ''		
		
				local choice				
				gam ch choice 1

				if [ "$choice" = 'y' ]; then
					echo "[DON'T EDIT THIS FILE MANUALLY, ONLY USING 'gam add' or 'gam rm <username>']" > "$accountspath"
					echo '' >> "$accountspath"
					
					echo "Created and initialized '${accountsfilename}' in '${srcpath}'"
				fi
			fi

			if ! [ -f "$configpath" ]; then
				touch "$configpath"
				echo "[DON'T EDIT THIS FILE MANUALLY, ONLY USING 'gam cc <config> <paramater>']" > "$configpath"
				echo '' >> "$configpath"
				echo 'autologin=true' >> "$configpath"

				echo "Created and initialized '${configfilename}' in '${srcpath}'"
			else
				if [ "$2" = 'default' ]; then
					return 0
				fi

				echo "WARNING: Found '${configfilename}' in '${srcpath}' with content:"
				echo ''
				cat "$configpath"
				echo ''				

				local choice				
				gam ch choice 1

				if [ "$choice" = 'y' ]; then
					echo "[DON'T EDIT THIS FILE MANUALLY, ONLY USING 'gam cc <config> <paramater>']" > "$configpath"
					echo '' >> "$configpath"
					echo 'autologin=true' >> "$configpath"

					echo "Created and initialized '${configfilename}' in '${srcpath}'"
				fi
			fi
		fi
	fi

	if [ "$cmd" = 'add' ]; then
		local username
		local email
		local token
		
		while true; do
			printf "Username: " ; IFS= read -r username
	
			if [ "$username" = '' ]; then
				echo "Error: Username can't be empty"
				continue
			fi
			
			if [ "$(sed -n "/username=${username}$/p" "$accountspath")" != '' ]; then
				echo "Error: Username already exists"
				continue
			fi
			
			local request
			local response_code
			
			request=$(curl -s -i "https://api.github.com/users/$username")
			response_code=$(echo "$request" | sed -n "1s/[^ ]* \([0-9]*\).*/\1/p")
			
			if [ "$response_code" = '200' ]; then
				break
			fi
			
			local message
			message=$(echo "$request" | sed -n "s/.*\"message\": \"\([^\"]*\)\".*/\1/p")
			
			if [ "$response_code" = '404' ]; then
				echo "Github Error Message: ${message}"
				echo "Error: Github account with username '${username}' doesn't exist"
			elif [ "$response_code" = '403' ]; then
				local time_until_request
				
				message=$(echo "$request" | sed -n "s/.*\"message\":\"\([^(]*\)\. .*/\1/p")
				time_until_request=$(echo "$request" | sed -n "s/.*x-ratelimit-reset: \([0-9]*\).*/\1/p")
				time_until_request=$(date --date="@${time_until_request}")
				
				echo "Github Error Message: ${message}"
				echo "Error: Github API request rate limit reached, please wait until '${time_until_request}' before trying to add an account"
				return 0
			fi
		done

		while true; do
			printf "Email: " ; IFS= read -r email
			
			if [ "$email" != '' ]; then
				break
			fi

			echo "Error: Email can't be empty"
		done

		while true; do
			printf "Token: " ; IFS= read -r token
			
			if [ "$token" != '' ]; then
				break
			fi

			echo "Error: Token can't be empty"
		done
		
		cat <<-EOF >> "$accountspath"
			[account]
			username=$username
			email=$email
			token=$token

		EOF

		echo "Added account '${username}'"
	fi

	if [ "$cmd" = 'rm' ]; then
		local username
		username="$2"

		if [ "$username" = '' ]; then
			echo "Error: Username can't be empty"
			echo ''
			gam ls

			return 0
		fi

		if [ "$(sed -n "/username=${username}$/p" "$accountspath")" = '' ]; then
			echo "Error: Account with username '${username}' doesn't exist"
			echo ""
			gam ls

			return 0
		fi
		
		if [ "$(git config --global user.name)" = "$username" ]; then
			gam logo
		fi

		sed -i -z "s/\[account\]\nusername=${username}\nemail=[^\n]*\ntoken=[^\n]*\n\n//" "$accountspath"
		echo "Deleted account '${username}'"
	fi

	if [ "$cmd" = 'log' ]; then
		local username
		local email
		local token
		
		username="$2"

		if [ "$username" = '' ]; then
			echo "Error: Username can't be empty"	
			echo ""
			gam ls
			
			return 0
		fi

		if [ "$(sed -n "/username=${username}$/p" "$accountspath")" = '' ]; then
			if [ "$3" = 'extract' ]; then
				echo "Error: During extraction, the seed account '${username}' wasn't found in ${accountspath}"
				echo "Change the seed (gam sd <username>) or register the account (gam add)"
			else
				echo "Error: Account with username '${username}' doesn't exist"
			fi
			
			echo ""
			gam ls

			return 0
		fi

		if [ "$username" = "$(git config --global user.name)" ]; then
			if [ "$3" != 'extract' ]; then
				echo "Already logged into account '${username}'"
			fi
			
			return 0
		fi
		
		email=$(sed -n -z "s/.*username=${username}\nemail=\([^\n]*\).*/\1/p" "$accountspath")
		token=$(sed -n -z "s/.*email=${email}\ntoken=\([^\n]*\).*/\1/p" "$accountspath")		
		
		git config --global user.name "$username"
		git config --global user.email "$email"
		echo "https://${username}:${token}@github.com" > ~/.git-credentials
		
		echo "Successfully logged as '${username}'"
	fi

	if [ "$cmd" = 'logo' ]; then
		local username
		username=$(git config --global user.name)
		
		if [ "$username" = '' ]; then
			echo 'Not logged in'
			return 0
		fi
		
		git config --global user.name ''
		git config --global user.email ''
		echo '' > ~/.git-credentials

		echo "Logged out of '${username}'"
	fi

	if [ "$cmd" = 'ls' ]; then
		local registered_accounts
		registered_accounts=$(sed -n "s/username=\(.*\)/\1/p" "$accountspath")
		
		if [ "$registered_accounts" = '' ]; then
			echo "No registered accounts found, use 'gam add' to add an account"
			return 0
		fi
		
		echo 'Registered accounts:'
		echo "$registered_accounts"
	fi

	if [ "$cmd" = 'lsaccs' ]; then
		echo ''
		gam ls
		echo ''
		
		echo "Accounts are shown from '${accountspath}':"
		echo ''
		cat "$accountspath"
	fi

	if [ "$cmd" = 'cu' ]; then
		local username
		username=$(git config --global user.name)

		if [ "$username" = '' ]; then
			echo 'Not logged in'
			return 0
		fi
		
		echo "Logged as '${username}'" 	
	fi

	if [ "$cmd" = 'cc' ]; then
		local config
		local parameter
		
		config="$2"
		parameter="$3"	
	
		if [ "$config" = '' ]; then
			echo "Error: Config can't be empty"
			echo ''
			gam lsco

			return 0
		fi

		if [ "$(sed -n "s/${config}=\(.*\)/\1/p" "$configpath")" = '' ]; then
			echo "Error: Config '${config}' doesn't exist"
			echo ''
			gam lsco

			return 0
		fi
		
		if [ "$parameter" = '' ]; then
			echo "Error: Parameter can't be empty"
			return 0
		fi

		sed -i "s/${config}.*/${config}=${parameter}/g" "$configpath"
		echo "Changed '${config}' to '${parameter}'"
	fi

	if [ "$cmd" = 'lsco' ]; then
		local configs
		configs=$(sed -n "/.*=.*/p" "$configpath")
		
		echo 'Configs:'
		echo "$configs"
	fi

	if [ "$cmd" = 'ed' ]; then
		local editfile
		editfile="$2"

		if [ "$editfile" = '' ]; then
			echo "Error: Edit file can't be empty"
			echo ''
			gam edf
	
			return 0
		fi

		if [ "$editfile" = 'accounts' ]; then
			vim "$accountspath"
	
			return 0
		fi

		if [ "$editfile" = 'config' ]; then
			vim "$configpath"
	
			return 0
		fi
	fi

	if [ "$cmd" = 'edf' ]; then
		echo "Editable files:"
		echo "accounts"
		echo "config"
	fi
	
	if [ "$cmd" = 'sd' ]; then
		local username
		local gitpath
		local error_message

		username="$2"
		
		if [ "$username" = '' ]; then
			echo "Error: Username can't be empty"
			echo ''
			gam ls

			return 0
		fi
		
		if [ "$(sed -n "/username=${username}$/p" "$accountspath")" = '' ]; then
			echo "Error: Account with username '${username}' doesn't exist"
			echo ''
			gam ls

			return 0
		fi

		gitpath=$(git rev-parse --show-toplevel 2>&1)
		error_message=$(echo "$gitpath" | sed -n "/fatal: /p")
		
		if [ "$error_message" != '' ]; then
			echo "Git Error Message: ${error_message}"
			
			if [ "$(echo "$error_message" | sed -n "/fatal: not a git repository/p")" != '' ]; then
				echo "Error: Current directory isn't in a local git repository"
			fi
			
			return 0
		fi

		local prevpath
		prevpath=$(pwd)

		cd "$gitpath" 'noextract'

		if [ -f '.gitignore' ]; then
			if [ "$(sed -n "/^${seedfilename}$/p" ".gitignore")" = '' ]; then
				local choice
				gam ch choice 2 "$seedfilename"

				if [ "$choice" = 'y' ]; then
					echo "$seedfilename" >> ".gitignore"
					echo "Added '${seedfilename}' to '.gitignore'"
				fi
			fi
		else
			local choice
			gam ch choice 3 "$seedfilename"

			if [ "$choice" = 'y' ]; then
				touch ".gitignore"
				echo "$seedfilename" > ".gitignore"
				echo "Created '.gitignore' and added '${seedfilename}' to it"
			fi
		fi

		if ! [ -f "$seedfilename" ]; then
			touch "$seedfilename"

			cat <<-EOF > "$seedfilename"
				[DON'T MANUALLY CHANGE THIS FILE, ONLY USE 'gam sd <username>']
				[This file is used as a seed for the account related to this local repository]
				username=$username
			EOF

			echo "Set account seed as '${username}' in '${seedfilename}' for local repository $(pwd)"
		else
			echo "WARNING: Found '${seedfilename}' in ${srcpath} with content:"
			echo ''
			cat "$seedfilename"
			echo ''	
		
			local choice
			gam ch choice 4 "$username"

			if [ "$choice" = 'y' ]; then
				cat <<-EOF > "$seedfilename"
					[DON'T MANUALLY CHANGE THIS FILE, ONLY USE 'gam sd <username>']
					[This file is used as a seed for the account related to this local repository]
					username=$username
				EOF

				echo "Set account seed as '${username}' in '${seedfilename}' for local repository $(pwd)" 
			fi
		fi

		cd "$prevpath" 'noextract'
	fi


	if [ "$cmd" = 'es' ]; then
		if [ "$2" = 'default' ] && [ "$(sed -n "s/autologin=\(.*\)/\1/p" "$configpath")" = 'false' ]; then
			return 0
		fi

		local gitpath
                local error_message

		gitpath=$(git rev-parse --show-toplevel 2>&1)
                error_message=$(echo "$gitpath" | sed -n "/fatal: /p")

                if [ "$error_message" != '' ]; then
                        if [ "$2" != 'default' ]; then
				echo "Git Error Message: ${error_message}"

				if [ "$(echo "$error_message" | sed -n "/fatal: not a git repository/p")" != '' ]; then
					echo "Error: Current directory isn't in a local git repository"
				fi
			fi

                        return 0
                fi

		local prevpath
                prevpath=$(pwd)

                cd "$gitpath" 'noextract'
		
		if [ -f '.gitignore' ]; then
			if [ "$(sed -n "/^${seedfilename}$/p" ".gitignore")" = '' ]; then
				local choice
				gam ch choice 2 "$seedfilename"

				if [ "$choice" = 'y' ]; then
					echo "$seedfilename" >> ".gitignore"
					echo "Added '${seedfilename}' to '.gitignore'"
				fi
			fi
		else
			local choice
			gam ch choice 3 "$seedfilename"

			if [ "$choice" = 'y' ]; then
				touch ".gitignore"
				echo "$seedfilename" > ".gitignore"
				echo "Created '.gitignore' and added '${seedfilename}' to it"
			fi
		fi

		if [ -f "$seedfilename" ]; then
			local username
			username=$(sed -n "s/username=\(.*\)/\1/p" "$seedfilename")
			gam log "$username" 'extract'
		else
			echo "Error: Seed file doesn't exist in local repository. Use 'gam sd <username>' while in local repository to create it"
		fi

		cd "$prevpath" 'noextract'
	fi
}

gam init default
