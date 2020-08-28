#!/usr/bin/env sh

while true; do
	if command -v apm; then
		xsetroot -name " $(apm -l)"
		sleep 30
	else
		xsetroot -name " todo"
		sleep 30
	fi
done &

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
	exec dwm
done
