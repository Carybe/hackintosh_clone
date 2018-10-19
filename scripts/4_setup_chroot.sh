#!/bin/bash -xe

mount /dev/sda4 /mnt
mount /dev/sda1 /mnt/boot/efi
mount -o force,rw /dev/sda2 /mnt/mnt

cp -R /scripts /mnt/tmp/scripts

for mountpoint in /dev /dev/pts /proc /sys /run
do
	mount -o rbind "${mountpoint}" /mnt"${mountpoint}"
done

chroot /mnt /tmp/scripts/5_fix_computer.sh
