#!/usr/bin/env zsh
vimode() {
	set -o vi
	bindkey '^R' history-incremental-search-backward
	zle-keymap-select () {
		if [ $KEYMAP = vicmd ]; then; printf "\033[2 q"; else; printf "\033[6 q"; fi
	}
	zle -N zle-keymap-select
	zle-line-init () { zle -K viins; printf "\033[6 q"; }
	zle -N zle-line-init
	bindkey -v
}
aliases() {
	hlprsucmd() { if which doas; then; doas $@; else; sudo $@; fi; }
	alias d="date"
	alias t="st &"
	alias ls="ls -F"
	alias v=$EDITOR
	alias V="hlprsucmd $EDITOR"
	alias mpvlq='mpv --ytdl-format="[height<420]"'
	alias gd='cd $(git rev-parse --show-toplevel 2>/dev/null || hg root)'
	alias cb='git rev-parse --abbrev-ref HEAD 2>/dev/null || cat .hg/bookmarks.current'
}
envvars() {
	if which vise 2>&1 >/dev/null; then; export EDITOR=vise; else; export EDITOR=vis; fi
	export DVTM_EDITOR=$EDITOR
	export PAGER=w3m
	export BROWSER=surf
	export PATH="$PATH:$HOME/.bin"
}
zshhist() {
	HISTFILE=/tmp/.zshhist
	HISTSIZE=1000
	SAVEHIST=1000
	setopt SHARE_HISTORY
}
promptandwindowtitle() {
	setopt prompt_subst # Enables variables in PS1
	setopt prompt_subst
	RPROMPT=""
	PROMPT='%F{blue}${durs}''%F{default}%n@%m: %F{cyan}${(%):-%~} %F{default}'

	preexec() {
		echo -en "\e]0;$1\a"; # E.g. set wintitle to cmd
		[ -z $DISPLAY ] || xdotool getactivewindow set_window --name "$1"
		pres="$(date +%s)"
	}
	precmd()  {
		#echo -en "\e]0;%~\a"; # E.g. set wintitle to dir
		[ -z $DISPLAY ] || xdotool getactivewindow set_window --name $(pwd)
		durs="$(echo $(date +%s) - $pres | bc 2>/dev/null)"
		if [ "$durs" -lt 1 ]; then
			durs=""
		else
			durs="${durs}s "
		fi
	}
}

vimode
envvars
aliases
zshhist
promptandwindowtitle
