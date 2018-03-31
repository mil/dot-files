default:
	nodefault

clean: clean-st clean-surf

clean-st:
	rm -fr st-mil/st/ st-mil/*.tar.xz
clean-surf:
	rm -fr surf-mil/surf-mil/ surf-mil/*.tar.xz

surf: clean-surf
	cd surf-mil && makepkg --clean -f
	cd surf-mil && sudo pacman --noconfirm -U surf-mil-*

st: clean-st
	cd st-mil && makepkg --clean -f
	cd st-mil && sudo pacman --noconfirm -U st-mil-*
