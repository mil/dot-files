#!/usr/bin/env sh
echo "Building the kernel"
PAR=8
time make defconfig
time ./scripts/kconfig/merge_config.sh .config config_overlay
time make -j$PAR
time make -j$PAR install
time make -j$PAR modules_install

echo "Building the initramfs"
KVER=`eselect kernel show | grep -oE linux-.+ | cut -d- -f2-`
dracut -a crypt -a lvm -a dm --force /boot/initramfs-$KVER.img $KVER

echo "Reconfiguring grub"
grub-mkconfig -o /boot/grub/grub.cfg
