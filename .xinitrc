xset +fp /usr/share/fonts/local &
xset +fp /usr/share/fonts/artwiz-fonts &
xset fp rehash &

xmodmap ~/.xmodmap &
feh --bg-scale ~/.wallpaper.jpg &
xbindkeys -f /home/mil/Code/Stable/foo-wm/config/.xbindkeysrc &
/home/mil/Code/Stable/foo-wm/foo-wm
