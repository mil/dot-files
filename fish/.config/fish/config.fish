# Env vars
setenv EDITOR vim
setenv GIT_EDITOR vim
setenv BROWSER firefox
setenv PAGER 'w3m -X'
setenv TZ America/Chicago

# Path & aliases
set -x PATH ~/.bin $PATH
set -x PATH /usr/lib/surfraw $PATH
set -x SURFRAW_graphical false

set -x LS_COLORS 'di=01;34'
alias cv='xclip -o'
alias cb='git rev-parse --abbrev-ref HEAD 2>/dev/null; or cat .hg/bookmarks.current'
alias tc='set GIT_COMMITER_DATE (date); git commit --amend --date (date)'
alias ff='firefox'
alias tf='terraform'
alias no='nomad'
alias pk='packer-io'
alias scmit='mktemp -p .; git add .; git commit -am "scrap"; git push origin master'

alias nm='w3m -X'

alias w3m='w3m -X'
alias pf='set -x PAGER cat'
alias po='set -x PAGER w3m -X'

function um; udisksctl mount -b /dev/disk/by-label/$argv; end
function uu; umount /run/media/mil/$argv; end

alias h='hg'
alias g='git'
alias m='make'
alias r='ranger'
alias p='w3m'
alias t='tree -C|w3m'

alias ga='git annex'
alias gd='cd (git rev-parse --show-toplevel 2>/dev/null; or hg root)'

# Set color
set fish_color_selection 'black'  '--bold'  '--background=grey'
set fish_color_search_match 'bryellow'  '--background=grey'
set fish_pager_color_progress 'brwhite'  '--background=grey'
set fish_pager_color_prefix 'red'  '--bold'  '--underline'

source /usr/share/autojump/autojump.fish

# Go-related
if test -d ~/Go
  export GOPATH='/home/mil/Go'
  set PATH $PATH $GOPATH/bin
end
if test -d ~/.Go
  export GOPATH='/home/mil/.Go'
  set PATH $PATH $GOPATH/bin
end

# For compat
export TERM='xterm-256color'
set fish_function_path $fish_function_path ~/.config/fish/plugin-foreign-env/functions
eval (dircolors -c)

# Fish title
function fish_title
  set -x pwd (dirs  | xargs)
  if test -z $argv[1]
    dirs
  else
    echo $argv[1] "($pwd)"
  end
end

# Start X at login
if status --is-login
    if test -z "$DISPLAY" -a $XDG_VTNR = 1
        startx -- -keeptty
    end
end

# At start
set fish_greeting ""
if not set --query SSH_CLIENT
  # Vi input
  fish_vi_key_bindings
  #fish_vi_mode

  #cal -j
  clear
  cat ~/.todo
end

# GPG-Related
gpg-connect-agent /bye
gpg-connect-agent updatestartuptty /bye > /dev/null
set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

# Additional
if test -d ~/.config/fish_additional
  source ~/.config/fish_additional/config.fish
end

# Additional / Work
if test -d ~/.config/fish_work
  source ~/.config/fish_work/config.fish
end
