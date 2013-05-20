xset +fp /usr/share/fonts/local &
xset +fp /usr/share/fonts/artwiz-fonts &
xset fp rehash &
xchainkeys &
autocutsel &
#devilspie &
compton &
unclutter &

xmodmap ~/.xmodmap &
feh --bg-scale ~/.wallpaper.jpg &

# setwm
bar-start &
xbindkeys &
exec /home/mil/Code/Github/meis-wm/meis-wm &
exec /home/mil/Code/Github/meis-wm/x-session
