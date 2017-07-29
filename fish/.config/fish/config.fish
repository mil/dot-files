# Env vars
setenv EDITOR vim
setenv GIT_EDITOR vim
setenv BROWSER w3m
setenv PAGER w3m
setenv TZ America/Chicago

# Path & aliases
set -x PATH /home/mil/.bin $PATH
set -x PATH /usr/lib/surfraw $PATH
alias cb='git rev-parse --abbrev-ref HEAD'
alias tc='set GIT_COMMITER_DATE (date); git commit --amend --date (date)'

# Go-related
export GOPATH='/home/mil/Go'
set PATH $PATH /home/mil/Go/bin

# Vi input
. /home/mil/.config/fish/vi-mode.fish
fish_vi_key_bindings

# For compat
export TERM='xterm-256color'
set fish_function_path $fish_function_path /home/mil/.config/fish/plugin-foreign-env/functions

# Start X at login
if status --is-login
    if test -z "$DISPLAY" -a $XDG_VTNR = 1
        startx -- -keeptty
    end
end
set fish_greeting ""
clear
#cat ~/.todo
cal -j

gpg-connect-agent /bye
gpg-connect-agent updatestartuptty /bye > /dev/null
set SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
