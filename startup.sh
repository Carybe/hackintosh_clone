#!/bin/bash -xe


LOCAL="/home/user/Desktop/JOGO_DO_GOLEIRO"

if [ $UID  -ne 0 ]
then
	echo 'Must be run as root!'
	exit 1
fi

mkdir -p /root/.ssh/
cp "${LOCAL}"/id_rsa /root/.ssh/
cp "${LOCAL}"/id_rsa.pub /root/.ssh/authorized_keys
cp -r "${LOCAL}"/scripts /

cd /

apt install pigz openssh-server -y
systemctl restart ssh

umount -l /home/user/Desktop/JOGO_DO_GOLEIRO
umount -l /boot/efi
