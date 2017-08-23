if [[ $HOSTNAME = music ]]; then
	  xrandr --setprovideroutputsource modesetting NVIDIA-0
  # xrandr --auto
  # 4k
fi

exec i3
