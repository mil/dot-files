if [[ $HOSTNAME = music ]]; then
	  xrandr --setprovideroutputsource modesetting NVIDIA-0
  # xrandr --auto
  # 4k
fi

if [[ $HOSTNAME = chip]]; then
  xmodmap ~/.Xmodmapd
fi






exec i3
