#!/usr/bin/env sh
# surf_tagyank.sh:
#   Usage: curl somesite | surf_tagyank.sh [SURFWINDOWID] [PROMPT] [XPATHs...]
#   Deps: xmllint, dmenu
#   Info: 
#     Designed to be used w/ surf externalpipe patch. Enables 'mouseless'
#     copying of codeblocks for example on stackoverflow. Given HTML stdin, 
#     extract contents from xpaths (default //pre //code) and show in dmenu 
#     (\n's sub'd for unicode ↵). Pipe picked item to xclip -i.
SURF_WINDOW="${1:-$(xprop -root | sed -n '/^_NET_ACTIVE_WINDOW/ s/.* //p')}"
DMENU_PROMPT="${2:-Tagyank}"
[[ ! -n "$3" ]] && XPATHS="//code //pre" # //* maybe nice
[[ -n "$3" ]] && XPATHS="${@:3}"

function copy() {
  CONTENT="$(cat -)"
  [[ -z "$CONTENT" ]] && exit
  type notify-send && notify-send "Yanked:" "$CONTENT"
  echo "$CONTENT" | xclip -i
}

function tags_extract() {
  input="$(cat -)"
  for xpath in $XPATHS;
  do
    echo "$input" | xmllint --html --xpath "$xpath" -
  done
}

function tagselect() {
  awk '{printf "%sNEWLINE_REPLACE", $0} END {printf "\n"}' |
    tags_extract $XPATHS |
    sed 's/NEWLINE_REPLACE/↵/g' |
    awk '{ gsub("<[^>]*>",""); print $0 }' |
    sed 's/&lt;/</g' |
    sed 's/&gt;/>/g' |
    sort |
    uniq |
    dmenu -w $SURF_WINDOW -p $DMENU_PROMPT -l 10 |
    sed 's/↵/\n/g'
}

tagselect | copy
