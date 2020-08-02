#!/usr/bin/env sh
# STDIN from externalpipe
# ARG0 = window id

STRINGS="$(sed -e 's/<[^>]*>//g' | grep -Eo '\S+' | tr -d '[:blank:]' | sort | uniq)"
PARTS="$(urlparts $(xprop -id $1 | grep _SURF_URI | grep -oE '".+"'  | tr -d '"'))"
BANGS="$(cat ~/.ddg_bangs)"

echo "$(
  echo "$PARTS"
  echo "$STRINGS"
  echo "$BANGS"
)"
