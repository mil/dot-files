xset +fp /usr/share/fonts/local &
xset +fp /usr/share/fonts/artwiz-fonts &
xset fp rehash &

xmodmap ~/.xmodmap &
feh --bg-scale ~/.wallpaper.jpg &

# setwm
bar-start &
xbindkeys -f /home/mil/Code/Github/foo-wm/config/.xbindkeysrc &
exec /home/mil/Code/Github/foo-wm/foo-wm
