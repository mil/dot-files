#!/usr/bin/env sh
#exec i3
battery_dwm_loop.sh &
sxhkd &
autocutsel &
xcape &
autocutsel -selection PRIMARY &
xsetroot -mod 2 2 -fg '#e8e8e8' -bg '#ffffff' &
xinput list | grep Synaptics | grep -oE 'id=([0-9]+)' | awk -F= '{print $2}' | xargs xinput --disable &
keynav &
xmodmap ~/.xmodmap &
dunst &

#exec dwm

while true; do
  # Log stderror to a file 
  dwm 2> ~/.dwm.log
  # No error logging
  #dwm >/dev/null 2>&amp;1
done

