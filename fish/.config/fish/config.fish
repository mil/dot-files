# Env vars
setenv EDITOR vim
setenv GIT_EDITOR vim
setenv BROWSER w3m
setenv PAGER w3m
setenv TZ America/Chicago

# Path & aliases
set -x PATH /home/mil/.bin $PATH
set -x PATH /usr/lib/surfraw $PATH
set -x SURFRAW_graphical false
alias cb='git rev-parse --abbrev-ref HEAD'
alias tc='set GIT_COMMITER_DATE (date); git commit --amend --date (date)'

# Go-related
if test -d /home/mil/Go
  export GOPATH='/home/mil/Go'
  set PATH $PATH /home/mil/Go/bin
end

# Vi input
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

# At start
set fish_greeting ""
if not set --query SSH_CLIENT
  cal -j
end

# GPG-Related
gpg-connect-agent /bye
gpg-connect-agent updatestartuptty /bye > /dev/null
set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

# Additional
if test -d /home/mil/.config/fish_additional
  source /home/mil/.config/fish_additional/config.fish
end

# Additional / Work
if test -d /home/mil/.config/fish_work
  source /home/mil/.config/fish_work/config.fish
end
