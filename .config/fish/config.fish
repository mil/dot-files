# Scripts Directory set -x PATH /home/mil/Scripts/Binaries $PATH
set -x PATH /home/mil/Scripts/Cron $PATH
set -x PATH /home/mil/Scripts/Data $PATH
set -x PATH /home/mil/Scripts/Downloaded $PATH
set -x PATH /home/mil/Scripts/Irc $PATH
set -x PATH /home/mil/Scripts/Misc $PATH
set -x PATH /home/mil/Scripts/Symlinks $PATH
set -x PATH /home/mil/Scripts/System $PATH
set -x PATH /home/mil/Scripts/Utilities $PATH
set -x PATH /home/mil/Scripts/Rpi $PATH
set -x PATH /home/mil/Scripts/Wm $PATH
set -x PATH /home/mil/Scripts/X $PATH
set -x PATH /usr/local/heroku/bin $PATH
set -x PATH /home/mil/.cabal/bin $PATH
set -x PATH /home/mil/.node_modules/*/bin $PATH
set -x PATH /home/mil/Code/Bitbucket/the-snazzy-desktop/webapp/node_modules/nodemon/bin $PATH

set -x PATH /usr/local/heroku/bin $PATH


# CPAN
set -x PATH /usr/bin/core_perl $PATH
set -x PATH /usr/bin/vendor_perl $PATH


# Color Wrapper
set -x PATH /usr/lib/cw $PATH

# RVM
set rvm_ignore_gemrc_issues 1
bash $HOME/.rvm/scripts/rvm
set -x PATH /home/mil/.rvm/bin $PATH
set -x PATH /home/mil/.gem/ruby/1.9.1/bin $PATH
set -x PATH /home/mil/.gem/ruby/2.0.0/bin $PATH
set -x PATH /home/mil/.gem/ruby/2.1.0/bin $PATH
set -x PATH /home/mil/.gem/ruby/2.2.0/bin $PATH
set -x PATH /home/mil/.aws-eb/eb/linux/python3 $PATH

. /home/mil/.config/fish/z.fish
. /home/mil/.config/fish/vi-mode.fish

#rvm > /d
alias l='lunch'
alias s='lunch'
alias j='z'
alias lsp='find (pwd)'
alias bd='cd ../'
alias x='nvm use v5.0.0; startx'
alias chromium='chromium --user-data-dir=/tmp/chromium-(uuidgen)'

alias t='tree'
alias t1='tree -L 1'
alias t2='tree -L 2'
alias t3='tree -L 3'


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

cat ~/.todo


set fish_function_path $fish_function_path /home/mil/.config/fish/plugin-foreign-env/functions

function nvm
	set NVM_DIR ~/.nvm
	fenv source $NVM_DIR/nvm.sh \; nvm $argv
end

