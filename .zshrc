### ZSH Options

#Promptinit
autoload -U promptinit
promptinit

source /etc/profile

#Auto Completej
setopt extendedglob
zmodload -a autocomplete
zmodload -a complist
zmodload zsh/complist

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors 'reply=( "=(#b)(*$VAR)(?)*=00=$color[green]=$color[bg-green]" )'
zstyle ':completion:*:*:*:*:hosts' list-colors '=*=30;41'
zstyle ':completion:*:*:*:*:users' list-colors '=*=$color[green]=$color[red]'

zstyle ":completion:*:*:$command:*:$tag" list-colors "=(#b)\
=$zshregex_with_brackets\
=$default_color_escape_number\
=$color_number_for_letters_in_first_bracket-pair\
=$color_number_for_letters_in_second_bracket-pair"     "..."

setopt correctall
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt INC_APPEND_HISTORY #share hist
setopt SHARE_HISTORY #share hist

zstyle ':completion:*' menu select
setopt completealiases


autoload -U compinit
compinit

#Colors
zmodload -a colors
autoload -U colors colors
autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
fi
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
done
PR_NO_COLOR="%{$terminfo[sgr0]%}"




#Version Control Shit
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable hg git bzr svn



#VARIABLES
export TZ="America/New_York"
export HISTSIZE=2000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

export EDITOR="vim -u ~/.vimrc"
export BROWSER="surf"


#Z
[[ -s ~/.autojump/etc/profile.d/autojump.zsh ]] && source ~/.autojump/etc/profile.d/autojump.zsh
export PATH="/usr/bin/vendor_perl:$PATH" #ls++
export PATH="/usr/lib/cw:$PATH" #Colorized output

# I do a lot of scripting apparently
export PATH="/home/mil/Scripts/Binaries:$PATH"
export PATH="/home/mil/Scripts/Cron:$PATH"
export PATH="/home/mil/Scripts/Data:$PATH"
export PATH="/home/mil/Scripts/Downloaded:$PATH"
export PATH="/home/mil/Scripts/Irc:$PATH"
export PATH="/home/mil/Scripts/Misc:$PATH"
export PATH="/home/mil/Scripts/Symlinks:$PATH"
export PATH="/home/mil/Scripts/System:$PATH"
export PATH="/home/mil/Scripts/Utilities:$PATH"
export PATH="/home/mil/Scripts/Wm:$PATH"
export PATH="/home/mil/Scripts/X:$PATH"

#RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
export rvm_ignore_gemrc_issues=1
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

PATH=$PATH:/home/mil/.gem/ruby/1.9.1/bin
export PATH

#VirtualENV Wrapper
export WORKON_HOME=~/.virtualenvs
source /usr/bin/virtualenvwrapper.sh




### ALIASES 
#alias ls='ls++'
alias q='exit'
alias ls='ls -1 --color -F'
alias goodnight='xset dpms force off'
alias v='vim'
alias back='cd "$OLDPWD";pwd'
alias grep='grep --colour'
alias tree='tree -C'
alias pacman='pacman-color'
alias vim='vim -u ~/.vimrc'
alias gcalc='pwdhash google.com | sed -n 2p | xargs -0 -I XXX gcalcli --user miles.sandlar@gmail.com --pw XXX'

alias ssh="TERM=linux ssh"

alias mwm='exec /home/mil/repos/github/mwm/mwm'



### FUNCTIONS

# PWDHash and PWDClip
pwdclip() {
    pwdhash $* | sed -n 2p | tr -d '\n' | xclip -sel clip
    #notify-send "clipped hash:: $1"
    echo "clippd"
}

# Extract Stuff
extract () {
if [ -f $1 ]; then
    case $1 in
             *.tar.bz2)   tar xjf $1        ;;
             *.tar.gz)    tar xzf $1     ;;
             *.bz2)       bunzip2 $1       ;;
             *.rar)       unrar e $1     ;;
             *.gz)        gunzip $1     ;;
             *.tar)       tar xf $1        ;;
             *.tbz2)      tar xjf $1      ;;
             *.tgz)       tar xzf $1       ;;
             *.zip)       unzip $1     ;;
             *.Z)         uncompress $1  ;;
             *.7z)        7z x $1    ;;
             *)           echo "'$1' cannot be extracted via extract()" ;;
         esac
	else
         echo "'$1' is not a valid file"
fi
}


###ZSH PLUGINS
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

#source /home/mil/.zsh/auto-fu.zsh
#zle-line-init () {auto-fu-init;}; zle -N zle-line-init
#zstyle ':completion:*' completer _oldlist _complete
#zle -N zle-keymap-select auto-fu-zle-keymap-select


###MISC

#VIM COMPATIBILITY & Inline Keybindings
set -o vi
bindkey -v


#Xdefaults colors in console
if [ "$TERM" = "linux" ]; then
    _SEDCMD='s/.*\*color\([0-9]\{1,\}\).*#\([0-9a-fA-F]\{6\}\).*/\1 \2/p'
    for i in $(sed -n "$_SEDCMD" $HOME/.Xdefaults | \
               awk '$1 < 16 {printf "\\e]P%X%s", $1, $2}'); do
        echo -en "$i"
    done
    clear
fi
THSTATUS=`tput tsl`
FHSTATUS=`tput fsl`

set_xterm_title() {
    if tput hs ; then
        print -Pn "$THSTATUS$@$FHSTATUS"
    fi
}
export TDIR="sdfasdf"

preexec() {
    set_xterm_title "urxvt< %n@%m: %50>...>$1%<<"
}

PROMPT=""
RPROMPT=""
setopt prompt_subst


#key setups
# bindkey SO HERE'S HOW I CONFIGURED THE PROMPT FOR ZSH:-v # vi key bindings
bindkey -e bold # emacs key bindings
bindkey ' ' magic-space # also do history expansion on space

# setup backspace correctly
stty erase `tput kbs`

#delete key
bindkey '\e[3~' delete-char

#home
bindkey '\e[1~' beginning-of-line



local IT="${terminfo[sitm]}${terminfo[bold]}"
local ST="${terminfo[sgr0]}${terminfo[ritm]}"

local FMT_BRANCH="%F{9}(%s:%F{7}%{$IT%}%r%{$ST%}%F{9}) %F{11}%B%b %K{235}%{$IT%}%u%c%{$ST%}%k"
local FMT_ACTION="(%F{3}%a%f)"
local FMT_PATH="%F{1}%R%F{2}/%S%f"

export XDG_CONFIG_HOME='/home/mil/.config'
setprompt() {
  local USER="%F{9}${terminfo[bold]}%n%f"
  local HOST="%F{4}%M%f"
  local PWD="%F{20}$($XDG_CONFIG_HOME/zsh/rzsh_path)%f"
  local TTY="%F{4}%y%f"
  local EXIT="%(?..%F{202}%?%f)"
  local TERMWIDTH=
  local PRMPT="${USER}@${HOST}: "

  if [[ "${vcs_info_msg_0_}" == "" ]]; then
    PROMPT="$PRMPT"
    RPROMPT="$PWD | $TTY"
  else
    PROMPT="${vcs_info_msg_0_}
$PRMPT"
  fi
}



precmd() {
    set_xterm_title "urxvt> %n@%m: %50<...<%~%<<"
		setprompt
}

#cat ~/.TODO 2> /dev/null

export PERL_LOCAL_LIB_ROOT="/home/mil/perl5";
export PERL_MB_OPT="--install_base /home/mil/perl5";
export PERL_MM_OPT="INSTALL_BASE=/home/mil/perl5";
export PERL5LIB="/home/mil/perl5/lib/perl5/i686-linux-thread-multi:/home/mil/perl5/lib/perl5";
export PATH="/home/mil/perl5/bin:$PATH";


touch /tmp/bar-refresh
