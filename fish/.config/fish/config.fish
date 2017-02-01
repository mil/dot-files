# .bin Directory set -x PATH /home/mil/Scripts/Binaries $PATH
set -x PATH /home/mil/.bin/Cron $PATH
set -x PATH /home/mil/.bin/Data $PATH
set -x PATH /home/mil/.bin/Downloaded $PATH
set -x PATH /home/mil/.bin/Irc $PATH
set -x PATH /home/mil/.bin/Misc $PATH
set -x PATH /home/mil/.bin/Symlinks $PATH
set -x PATH /home/mil/.bin/System $PATH
set -x PATH /home/mil/.bin/Utilities $PATH
set -x PATH /home/mil/.bin/Rpi $PATH
set -x PATH /home/mil/.bin/Wm $PATH
set -x PATH /home/mil/.bin/X $PATH
set -x PATH /home/mil/.node_modules/*/bin $PATH

# Color Wrapper
. /home/mil/.config/fish/z.fish
. /home/mil/.config/fish/vi-mode.fish

#rvm > /d
alias j='z'
alias lsp='find (pwd)'
alias bd='cd ../'
alias x='nvm use v5.0.0; startx'
alias chromium='chromium --user-data-dir=/tmp/chromium-(uuidgen)'

alias t='tree'
alias t1='tree -L 1'
alias t2='tree -L 2'
alias t3='tree -L 3'
alias cb='git rev-parse --abbrev-ref HEAD'
alias bbd='git for-each-ref --sort=-committerdate refs/heads/'
alias tc='set GIT_COMMITER_DATE (date); git commit --amend --date (date)'


setenv EDITOR vim
setenv GIT_EDITOR vim
setenv BROWSER surf
setenv TZ America/Chicago

set fish_greeting ""


# fish git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch red

# Status Chars
set __fish_git_prompt_char_dirtystate '☡'
set __fish_git_prompt_char_stagedstate '→'
set __fish_git_prompt_char_stashstate '↩'
set __fish_git_prompt_char_upstream_ahead '↑'
set __fish_git_prompt_char_upstream_behind '↓'

#function fish_right_prompt
#  printf '%s' (__fish_git_prompt)
#end

#function fish_prompt
#  set last_status $status
#  set_color $fish_color_cwd
#  printf '%s→ ' (prompt_pwd)
#  set_color normal
#  set_color normal
#  #z --add $PWD
#  #set_color $fish_color_cwd
#  #set_color normal
#end

#cat ~/.todo


set fish_function_path $fish_function_path /home/mil/.config/fish/plugin-foreign-env/functions

function nvm
	set NVM_DIR ~/.nvm
	fenv source $NVM_DIR/nvm.sh \; nvm $argv
end


export TERM='xterm-256color'
fish_vi_key_bindings
clear
