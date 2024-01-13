#!/usr/bin/env sh
CFGFILE=~/.asoundrc

CURDEV="$(cat $CFGFILE | grep -E '[0-9]+')"

if echo $CURDEV | grep 1; then
  NEWDEV=0
else
  NEWDEV=1
fi

echo "
defaults.pcm.card $NEWDEV
defaults.ctl.card $NEWDEV
" > $CFGFILE
