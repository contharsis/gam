# gam
gam - github account manager  
Use it to manage multiple accounts on one system

# commands  
GAM - Github Account Manager - Put everything in an environment loader (e.g. ~/.bashrc) then reload it (e.g. source ~/.bashrc)

Commands:  
gam - Main command, used to access the others, write it before them (e.g. gam init, gam add and so on) (Use it on its own for help)  
help - Show this text  
init - Clear the config and initialize it  
add - Add an account  
rm - Remove an account - 1 Argument - Account username  
log - Log into an account - 1 Argument - Account username  
logo - Log out of currently logged in account  
ls - List only usernames of registered accounts  
lsaccs - List all information about the registered accounts  
cu - Tell the currently logged account and its username  
cc - Change configs - 1 Argument - Config option  
ed - Manually edit configuration files (Not reccomended) - 1 Argument - config file name  
edf - List config file names  
sd - Set seed in current local repository (Has to be in current directory) - 1 Argument - Username of account to be seeded  
es - Extract seed from current local repository (Has to be in current directory)  

Config:  
Automatic login is enabled by default. When entering a seeded folder, the user will automatically
be logged as the account seeded. To disable this use 'gam cc \<config\> \<parameter\>' and set it to false
