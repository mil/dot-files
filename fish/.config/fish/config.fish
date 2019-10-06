# Helper fns
function add_to_path_if_exists
  if test -d $argv
    set -x PATH $argv $PATH
  end
end


# Main
function setup_envvars_and_path
  # Env vars
  setenv SXHKD_SHELL sh
  setenv GO111MODULE on
  setenv EDITOR vis
  setenv GIT_EDITOR vis
  setenv BROWSER firefox
  setenv XDG_CONFIG_HOME ~/.config
  setenv PAGER w3n
  setenv TZ America/Chicago
  setenv SURFRAW_graphical false
  setenv RANGER_LOAD_DEFAULT_RC FALSE

  # Java
  export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on"
  export BOOT_JVM_OPTIONS='-client -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Xverify:none'


  # Path
  add_to_path_if_exists /opt/bin
  add_to_path_if_exists /home/$USER/.cargo/bin
  add_to_path_if_exists /usr/share/surfraw
  add_to_path_if_exists /usr/lib/surfraw
  add_to_path_if_exists /home/$USER/.bin
  add_to_path_if_exists /home/$USER/.bin_wmutils
  add_to_path_if_exists /usr/lib64/go/bin/goimports
  add_to_path_if_exists /usr/local/bin
end


function setup_shortcuts
  abbr -a jdi 'killall jackd || true && jackd -r -d alsa -d 'hw:0' -r 44100'
  abbr -a jdu 'killall jackd || true && jackd -r -d alsa -r 44100 -i 2 -d hw:USB'

  abbr -a ytdlpl 'youtube-dl -xo "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s"'
  abbr -a syncwatch watch grep -e Dirty: -e Writeback: /proc/meminfo

  abbr -a inv 'xcalib -invert -alter'

  abbr -a d date
  abbr -a bw set -x TERM vt102

  abbr -a nb 'killall newsboat || sleep 0.1 && newsboat'
  abbr -a we weechat
  abbr -a g git
  abbr -a gco git checkout
  abbr -a gc git commit
  abbr -a yt youtube
  abbr -a h hg
  abbr -a r ranger
  abbr -a dg git diff HEAD
  abbr -a cati siv4 -s30

  # Pager
  abbr -a pgo 'set -x PAGER cat'
  abbr -a pgw 'set -x PAGER w3n'
  abbr -a pgv 'set -x PAGER visp'

  alias ag="ag --color-path 35 --color-match '1;31' --color-line-number 32"


  alias q='quit'
  alias m='w3m'
  alias c='cd'
  alias tw='tree -C|w3m'
  alias gd='cd (git rev-parse --show-toplevel 2>/dev/null; or hg root)'
  alias cb='git rev-parse --abbrev-ref HEAD 2>/dev/null; or cat .hg/bookmarks.current'
  alias tc='set GIT_COMMITER_DATE (date); git commit --amend --date (date)'
end



function setup_colorsconfig
  set fish_color_selection 'black'  '--bold'  '--background=grey'
  set fish_color_search_match 'bryellow'  '--background=grey'
  set fish_pager_color_progress 'brwhite'  '--background=grey'
  set fish_pager_color_prefix 'red'  '--bold'  '--underline'
  set -x LS_COLORS 'di=01;34'
end



function setup_promptconfig
  set fish_greeting ""
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
end



function setup_vimlike
  # C-x in insert mode to edit
  function edit_commandline
    set -q EDITOR; or return 1
    set -l tmpfile (mktemp); or return 1
    commandline > $tmpfile
    eval $EDITOR $tmpfile
    commandline -r -- (cat $tmpfile)
    rm $tmpfile
  end
  function fish_user_key_bindings; bind -M insert \cx edit_commandline; end

  # Keybindings
  #if not set --query SSH_CLIENT
    fish_vi_key_bindings #fish_vi_mode
  #  #cat ~/.todo
  #end

  # Prompt
  function fish_mode_prompt --description 'Displays the current mode'
    switch $fish_bind_mode
        case default; set_color --bold --background red white
        case insert;  set_color --bold --background green white
        case visual;  set_color --bold --background magenta white
    end

    #date '+%H%M'
    msformat $CMD_DURATION

    set_color normal
    echo -n ' '
  end
end



function setup_addons_and_misc
  # J
  source /usr/share/autojump/autojump.fish 2> /dev/null

  # X autostart
  #if status --is-login
  #    if test -z "$DISPLAY" -a $XDG_VTNR = 1
  #        startx -- -keeptty
  #    end
  #end

  # Go-related
  if test -d ~/Go; export GOPATH=/home/$USER/Go; end
  if test -d ~/.Go; export GOPATH=/home/$USER/.Go; end
  add_to_path_if_exists $GOPATH/bin

  # For compat
  export TERM='xterm-256color'
  set fish_function_path $fish_function_path ~/.config/fish/plugin-foreign-env/functions
  eval (dircolors -c)

  # Additional-configs if existant
  if test -d ~/.config/fish_additional; source ~/.config/fish_additional/config.fish; end
  if test -d ~/.config/fish_work; source ~/.config/fish_work/config.fish; end
end



setup_envvars_and_path
setup_shortcuts
setup_vimlike
setup_promptconfig
setup_colorsconfig
setup_addons_and_misc
