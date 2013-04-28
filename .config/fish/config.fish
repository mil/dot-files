# I do a lot of scripting 
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
set -x PATH /usr/lib/cw $PATH

set EDITOR vim
set GIT_EDITOR vim
set BROWSER surf
set TZ America/New_York

set fish_greeting ""

function fish_prompt
  set_color $fish_color_cwd
  echo -n (prompt_pwd)
  set_color normal
  echo -n ' > '
end
