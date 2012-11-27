xset +fp /usr/share/fonts/local &
xset +fp /usr/share/fonts/artwiz-fonts &
xset fp rehash &

xmodmap ~/.xmodmap &
feh --bg-scale ~/.wallpaper.jpg &

# setwm
if [ -f "/usr/bin/tpb" ];
then
sudo tpb &
fi &
bar-start &
xbindkeys &
dunst &
keynav &
exec /home/mil/Code/Stable/foo-wm/foo-wm
