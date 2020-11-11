#!/usr/bin/env sh

while true; do
	MEMFREE="$(free -m | grep Mem | awk -F ' ' '{print $4}')M"
	DATE="$(date +'%H:%M' | tr -d ' ')"
	BAT="unimplemented"
	if command -v apm; then
		BAT="$(apm -l)%"
	elif [ -e /sys/class/power_supply/BAT0/capacity ]; then
		BAT="$(cat /sys/class/power_supply/BAT0/capacity)%"
	elif [ -e /sys/class/power_supply/BAT1/capacity ]; then
		BAT="$(cat /sys/class/power_supply/BAT1/capacity)%"
	fi
	xsetroot -name " $DATE | $MEMFREE | $BAT"
	sleep 30
done &

xinput list | grep Synaptics | grep -oE 'id=[0-9]+' | cut -d= -f2 | xargs xinput disable
autocutsel -selection PRIMARY & autocutsel &
xsetroot -rv -mod 3 2 -fg '#cfcfcf' -bg '#ffffff' &
xmodmap -e "clear lock" -e "keycode 0x42 = Escape" &
keynav & 

if stat /dev/wsmouse; then
	xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation" 1
	xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation Button" 2
	xinput | grep /dev/wsmouse0 | grep -oE 'id=[0-9]+' | cut -d= -f2 | xargs xinput --float
fi

while true; do
	exec dwm 2> ~/.dwm.log
done
