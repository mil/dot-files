xset +fp /usr/share/fonts/local &
xset +fp /usr/share/fonts/artwiz-fonts &
xset fp rehash &
#xchainkeys &
autocutsel &
#devilspie &
compton &
unclutter &

xmodmap ~/.xmodmap &
feh --bg-scale ~/.wallpaper.jpg &

# setwm
if [ -f "/usr/bin/tpb" ];
then
sudo tpb &
fi &
bar-start &
sxhkd -c ~/.sxhkd-foo &
dunst &
keynav &
exec foo-wm
