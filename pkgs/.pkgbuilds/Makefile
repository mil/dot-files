default:
	nodefault

clean: clean-st clean-surf clean-mstat

clean-st:
	rm -fr mil-st/st/ mil-st/*.tar.xz
clean-surf:
	rm -fr mil-surf/mil-surf/ mil-surf/*.tar.xz
clean-mstat:
	rm -fr mil-mstat/src mil-mstat/pkg mil-mstat/*.tar.xz

surf: clean-surf
	cd mil-surf && makepkg --clean -f
	cd mil-surf && sudo pacman --noconfirm -U mil-surf-*

st: clean-st
	cd mil-st && makepkg --clean -f
	cd mil-st && sudo pacman --noconfirm -U mil-st-*

mstat: clean-mstat
	cd mil-mstat && makepkg --clean -f
	cd mil-mstat && sudo pacman --noconfirm -U mil-mstat-*

