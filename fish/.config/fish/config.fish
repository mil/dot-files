# Env vars
setenv EDITOR vis
setenv GIT_EDITOR vis
setenv BROWSER firefox
setenv PAGER 'w3m -X'
setenv TZ America/Chicago

# Path & aliases
set -x PATH ~/.bin $PATH

if test -d /usr/lib/surfraw
  set -x PATH /usr/lib/surfraw $PATH
end
if test -d /usr/share/surfraw
  set -x PATH /usr/share/surfraw $PATH
end


if test -d /home/$USER/.cargo/bin
  set -x PATH /home/$USER/.cargo/bin $PATH
end

set -x SURFRAW_graphical false

set -x LEDGER_FILE ~/.ledger.journal

set -x STARDICT_DATA_DIR ~/.sdcv_data_dir
function def; sdcv -n $argv | eval $PAGER; end

set -x LS_COLORS 'di=01;34'
alias cv='xclip -o'
alias cb='git rev-parse --abbrev-ref HEAD 2>/dev/null; or cat .hg/bookmarks.current'
alias tc='set GIT_COMMITER_DATE (date); git commit --amend --date (date)'
alias ff='firefox'
alias tf='terraform'
alias no='nomad'
alias pk='packer-io'
alias scmit='mktemp -p .; git add .; git commit -am "scrap"; git push origin master'

alias lyrics='duckduckgo -l site:genius.com'

alias nm='w3m -X'

alias w3m='w3m -X'
alias pf='set -x PAGER cat'
alias po='set -x PAGER w3m -X'
alias pv='set -x PAGER vis -'

function um; udisksctl mount -b /dev/disk/by-label/$argv; end
function uu; umount /run/media/mil/$argv; end


set -x NNN_USE_EDITOR 1
alias n='nnn'
alias q='quit'

alias h='hg'
alias g='git'
alias r='ranger'
alias f='tree -C -L 1'
alias ff='tree -C -L 2'
alias fff='tree -C -L 3'
alias ffff='tree -C -L 4'
alias fffff='tree -C -L 5'


alias m='w3m'
alias u='cd ..'
alias c='cd'
alias tw='tree -C|w3m'
alias v='vis'

alias gd='cd (git rev-parse --show-toplevel 2>/dev/null; or hg root)'

# Set color
set fish_color_selection 'black'  '--bold'  '--background=grey'
set fish_color_search_match 'bryellow'  '--background=grey'
set fish_pager_color_progress 'brwhite'  '--background=grey'
set fish_pager_color_prefix 'red'  '--bold'  '--underline'

source /usr/share/autojump/autojump.fish

# Go-related
if test -d ~/Go
  export GOPATH=/home/$USER/Go
  set PATH $PATH $GOPATH/bin
end
if test -d ~/.Go
  export GOPATH=/home/$USER/.Go
  set PATH $PATH $GOPATH/bin
end

# For compat
export TERM='xterm-256color'
set fish_function_path $fish_function_path ~/.config/fish/plugin-foreign-env/functions
eval (dircolors -c)

# Fish title
function fish_title
  set -x pwd (dirs  | xargs)
  if test -n "$ft"
    echo $ft
  else if test -z $argv[1]
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

function edit_commandline
  set -q EDITOR; or return 1
  set -l tmpfile (mktemp); or return 1
  commandline > $tmpfile
  eval $EDITOR $tmpfile
  commandline -r -- (cat $tmpfile)
  rm $tmpfile
end

function d
  set -l tmpfile (mktemp); or return 1
  eval fzf | tr -d "\n" > $tmpfile
  commandline -r -- "vis "(cat $tmpfile)
end

function fish_user_key_bindings
  bind -M insert \cx edit_commandline
  bind -M insert \cs d
end


# At start
set fish_greeting ""
if not set --query SSH_CLIENT
  # Vi input
  fish_vi_key_bindings
  #clear
  #fish_vi_mode

  #cal -j
  clear
  cat ~/.todo
end

# Additional
if test -d ~/.config/fish_additional
  source ~/.config/fish_additional/config.fish
end

# Additional / Work
if test -d ~/.config/fish_work
  source ~/.config/fish_work/config.fish
end
