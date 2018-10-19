#!/bin/bash -xe

if [ $# -lt 1 ]
then
	echo 'You must specify a host from which will receive the images.'
	exit 1
fi

HOST=$1
HOST_HOSTNAME=$(ssh -o StrictHostKeyChecking=false "${HOST}" hostname)
echo "Copying images from ${HOST_HOSTNAME}"

for disk in /dev/sda1 /dev/sda4 /dev/sda5
do
	ssh -o StrictHostKeyChecking=false $HOST "dd if=${disk} bs=1024k | pigz -c -b2048" | pigz -dc -b2048 | dd bs=1024k of=${disk} status=progress
	fsck -f "${disk}"
done
