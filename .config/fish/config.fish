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
set -x PATH /home/mil/Scripts/Rpi $PATH
set -x PATH /home/mil/Scripts/Wm $PATH
set -x PATH /home/mil/Scripts/X $PATH
set -x PATH /usr/local/heroku/bin $PATH
set -x PATH /home/mil/.cabal/bin $PATH

set -x PATH /usr/local/heroku/bin $PATH


# CPAN
set -x PATH /usr/bin/core_perl $PATH


# Color Wrapper
set -x PATH /usr/lib/cw $PATH

# RVM
set rvm_ignore_gemrc_issues 1
bash $HOME/.rvm/scripts/rvm
set -x PATH /home/mil/.rvm/bin $PATH
set -x PATH /home/mil/.gem/ruby/1.9.1/bin $PATH
set -x PATH /home/mil/.gem/ruby/2.0.0/bin $PATH
set -x PATH /home/mil/.aws-eb/eb/linux/python3 $PATH

. /home/mil/.config/fish/z.fish
. /home/mil/.config/fish/vi-mode.fish

#rvm > /d
alias j='z'
alias bd='cd ../'


setenv EDITOR vim
setenv GIT_EDITOR vim
setenv BROWSER surf
setenv TZ America/New_York

set fish_greeting ""


function fish_prompt
  z --add $PWD
  set_color $fish_color_cwd
  echo -n (prompt_pwd)
  set_color normal
  echo -n ' > '
end

cat ~/.todo
