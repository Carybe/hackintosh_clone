#!/bin/bash -xe

if [ $# -lt 1 ]
then
	echo 'You must specify a client which must receive the images.'
	exit 1
fi

CLIENT=$1
CLIENT_HOSTNAME=$(ssh StrictHostKeyChecking=false "${CLIENT}" hostname)
echo "Copying images to ${CLIENT_HOSTNAME}"

for disk in /dev/sda1 /dev/sda4 /dev/sda5
do
	dd if="${disk}" bs=1024k | pigz -c -b2048 | ssh StrictHostKeyChecking=false "${CLIENT}" "pigz -dc -b2048 | dd bs=1024k of=${disk} status=progress"
	fsck -f "${disk}"
done
