#!/bin/bash -xe

# Copy the partitions from a specific host to its respectives counterparts

if [ $# -lt 1 ]
then
	echo 'You must specify a host from which will receive the images.'
	exit 1
fi

HOST=$1
HOST_HOSTNAME=$(ssh -o StrictHostKeyChecking=false "${HOST}" hostname)
echo "Copying images from ${HOST_HOSTNAME}"

# UEFI
ssh -o StrictHostKeyChecking=false $HOST \
	"dd if=/dev/sda1 bs=1024k | pigz -c -b2048" | \
	pigz -dc -b2048 | \
	dd bs=1024k of=/dev/sda1 status=progress
fsck -f /dev/sda1

# The clone server has an extra partition between the
# linux destination partition and the mac partitions
# so it can host a minified mac partition
# (MacOS disk utility doesnt let me shrink a volume if
# it doesnt have another volume after it)
# so it can host a minified mac partition

# ROOT
ssh -o StrictHostKeyChecking=false $HOST \
	"dd if=/dev/sda5 bs=1024k | pigz -c -b2048" | \
	pigz -dc -b2048 | \
	dd bs=1024k of=/dev/sda4 status=progress
fsck -f /dev/sda4

# HOME
ssh -o StrictHostKeyChecking=false $HOST \
	"dd if=/dev/sda6 bs=1024k | pigz -c -b2048" | \
	pigz -dc -b2048 | \
	dd bs=1024k of=/dev/sda5 status=progress
fsck -f /dev/sda5
