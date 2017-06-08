while true; do
   xsetroot -name "$( date +"%F (%U/53 %u/7)" )"
   sleep 1m
done &

xmodmap ~/.xmodmap &
xrdb ~/.Xresources &
exec feh --bg-scale ~/.wallpaper.jpg &
exec dwm
