#!/usr/bin/env zsh
vimode() {
	set -o vi
	bindkey '^R' history-incremental-search-backward
	zle-keymap-select () {
		if [ $KEYMAP = vicmd ]; then; printf "\033[2 q"; else; printf "\033[6 q"; fi
	}
	function zle-line-init zle-keymap-select {
		VIM_PROMPT="%{%F{blue}%}[cmd]%  %{$reset_color%}"
		PROMPT="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}$PROMPT"
		zle reset-prompt
		promptandwindowtitle
	}
	zle -N zle-keymap-select
	zle-line-init () { zle -K viins; printf "\033[6 q"; }
	zle -N zle-line-init
	bindkey -M vicmd "^E" edit-command-line
	bindkey -v
}
aliases() {
	hlprsucmd() { if which doas; then; doas $@; else; sudo $@; fi; }
	alias d="date"
	alias t="tail"
	alias h="head"
	alias n="st &"
	alias ls="ls -F"
	alias v=$EDITOR
	alias V="hlprsucmd $EDITOR"
	alias ytp='youtube-dl ytsearch5:asmr --get-id | sed 's#^#ytdl://#' | xargs -IC mpv -v --ytdl-format="[height<420]" C'
	alias ytdlpl='youtube-dl -xo "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s"'
	alias mpvlq='mpv -v --ytdl-format="[height<420]"'
	alias gd='cd $(git rev-parse --show-toplevel 2>/dev/null || hg root)'
	alias cb='git rev-parse --abbrev-ref HEAD 2>/dev/null || cat .hg/bookmarks.current'
	alias nixbuildenv="env -i nix-shell -I nixpkgs=/home/m/Repos/nixpkgs '<nixpkgs>' -A $1"
}
envvars() {
	if which vise 2>&1 >/dev/null; then; export EDITOR=vise; else; export EDITOR=vis; fi
	export DVTM_EDITOR=$EDITOR
	export ST_INVERT=0
	export PAGER=w3m
	export BROWSER=surf

	export PATH="$PATH:$HOME/.bin_extra"
	export PATH="$PATH:$HOME/.bin"

	[ -d /home/m/Repos/blip/zig-cache/bin ] && 
		export PATH="$PATH:/home/m/Repos/blip/zig-cache/bin"
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
		[ -z $DISPLAY ] || xdotool getactivewindow set_window --name "$(pwd)"
		durs="$(echo $(date +%s) - $pres | bc 2>/dev/null)"
		if [ "$durs" -lt 1 ]; then
			durs=""
		else
			durs="${durs}s "
		fi
	}
}
setupfasd() {
	eval "$(
		fasd --init \
			posix-alias zsh-hook zsh-ccomp zsh-ccomp-install \
			zsh-wcomp zsh-wcomp-install
	)"
	bindkey '^Xa' fasd-complete # files + dirs
	bindkey '^Xf' fasd-complete-f # files
	bindkey '^Xd' fasd-complete-d # dirs
}
machinespecific() {
	[ -f $HOME/.zshrc.machine ] && source $HOME/.zshrc.machine
}
gpgagent() {
  pkill pinentry
  pidof gpg-agent >/dev/null || gpg-agent --daemon --enable-ssh-support
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  if [ -z $DISPLAY ]; then
    echo "pinentry-program $(which pinentry-curses)" > ~/.gnupg/gpg-agent.conf
    export GPG_TTY=$(tty)
  else
    echo "pinentry-program $(which pinentry-gtk-2)" > ~/.gnupg/gpg-agent.conf
  fi
}

setupautosuggestions() {
  P=/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=gray,underline"
  [ -f $P ] && source $P
}

setupautosuggestions
envvars
aliases
zshhist
promptandwindowtitle
vimode
setupfasd
machinespecific
gpgagent
