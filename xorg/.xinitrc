#!/usr/bin/env bash
if [[ $HOSTNAME = h ]]; then
	#xrandr --setprovideroutputsource modesetting NVIDIA-0
  # xrandr --auto
  # 4k
  xmodmap ~/.xmodmap
else
  exec i3
fi

xmodmap ~/.xmodmap
cat ~/.i3/config ~/.i3/supplement_`hostname` > /tmp/i3-tmpconfig
exec i3 -c /tmp/i3-tmpconfig
