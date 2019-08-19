#!/usr/bin/env sh
#exec i3
battery_dwm_loop.sh &
sxhkd &
autocutsel &
autocutsel -selection PRIMARY &
xsetroot -mod 2 2 -fg '#e8e8e8' -bg '#ffffff' &
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

