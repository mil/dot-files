#!/usr/bin/env sh

while true; do
	MEMFREE="$(free -m | grep Mem | awk -F ' ' '{print $4}')M"
	DATE="$(date +'%H:%M' | tr -d ' ')"
	BAT="unimplemented"
	if command -v apm; then
		BAT="$(apm -l)%"
	elif [ -e /sys/class/power_supply/axp20x-battery/capacity ]; then
		BAT="$(cat /sys/class/power_supply/axp20x-battery/capacity)%"
	elif [ -e /sys/class/power_supply/BAT0/capacity ]; then
		BAT="$(cat /sys/class/power_supply/BAT0/capacity)%"
	elif [ -e /sys/class/power_supply/BAT1/capacity ]; then
		BAT="$(cat /sys/class/power_supply/BAT1/capacity)%"
	fi

	if [ -e /sys/class/power_supply/axp20x-battery/capacity ]; then
		BAT2=" / $(cat /sys/class/power_supply/ip5xxx-charger/capacity)%"
	fi

	xsetroot -name " $DATE | $MEMFREE | ${BAT}${BAT2}"
	sleep 30
done &

xinput list | grep Synaptics | grep -oE 'id=[0-9]+' | cut -d= -f2 | xargs xinput disable
autocutsel -selection PRIMARY & autocutsel &
xsetroot -rv -mod 3 2 -fg '#cfcfcf' -bg '#ffffff' &
xmodmap -e "clear lock" -e "keycode 0x42 = Escape" &
keynav & 

lisgd -d /dev/input/by-path/platform-1c2ac00.i2c-event -v -g '1,DLUR,*,*,,sh -c "pidof ppxscreenlock || ppxscreenlock"' &

if stat /dev/wsmouse; then
	xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation" 1
	xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation Button" 2
	xinput | grep /dev/wsmouse0 | grep -oE 'id=[0-9]+' | cut -d= -f2 | xargs xinput --float
fi

export XDG_RUNTIME_DIR=$HOME/.config

while true; do
	exec dwm 2> ~/.dwm.log
done
