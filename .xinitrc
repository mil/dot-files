xset +fp /usr/share/fonts/local &
xset +fp /usr/share/fonts/artwiz-fonts &
xset fp rehash &
xchainkeys &
autocutsel &

xmodmap ~/.xmodmap &
feh --bg-scale ~/.wallpaper.jpg &

# setwm
keynav &
dunst &
exec i3
