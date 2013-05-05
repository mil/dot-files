# Scripts Directory
set -x PATH /home/mil/Scripts/Binaries $PATH
set -x PATH /home/mil/Scripts/Cron $PATH
set -x PATH /home/mil/Scripts/Data $PATH
set -x PATH /home/mil/Scripts/Downloaded $PATH
set -x PATH /home/mil/Scripts/Irc $PATH
set -x PATH /home/mil/Scripts/Misc $PATH
set -x PATH /home/mil/Scripts/Symlinks $PATH
set -x PATH /home/mil/Scripts/System $PATH
set -x PATH /home/mil/Scripts/Utilities $PATH
set -x PATH /home/mil/Scripts/Wm $PATH
set -x PATH /home/mil/Scripts/X $PATH

set rvm_ignore_gemrc_issues 1
# Color Wrapper
set -x PATH /usr/lib/cw $PATH

# RVM
bash $HOME/.rvm/scripts/rvm
set -x PATH /home/mil/.gem/ruby/1.9.1/bin $PATH

. /home/mil/.config/fish/z.fish
. /home/mil/.config/fish/vi-mode.fish

#rvm > /dev/null


alias j='z'


set EDITOR vim
set GIT_EDITOR vim
set BROWSER surf
set TZ America/New_York

set fish_greeting ""


function fish_prompt
  z --add $PWD
  set_color $fish_color_cwd
  echo -n (prompt_pwd)
  set_color normal
  echo -n ' > '
end
