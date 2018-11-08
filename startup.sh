#!/bin/bash -xe

# First script to be run on both systems (client AND server)

LOCAL=$(dirname $(realpath $0))

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

MOUNTED_POINTS=$(lsblk --all --noheadings --output MOUNTPOINT | grep -v ^$)

for mp in "${MOUNTED_POINTS}"
do
	umount -l $mp
done
