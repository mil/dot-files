xset +fp /usr/share/fonts/local &
xset +fp /usr/share/fonts/artwiz-fonts &
xset fp rehash &
#xchainkeys &
autocutsel &
#devilspie &
compton &
#unclutter &
xrdb /home/mil/.Xresources &

ID=`xinput list | grep -Eio 'touchpad\s*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}'`
xinput disable $ID
xmodmap ~/.xmodmap &
feh --bg-scale ~/.wallpaper.jpg &

# setwm
keynav &
dunst &
exec i3
