#!/bin/bash -xe

# Copy the partitions to a specific client

if [ $# -lt 1 ]
then
	echo 'You must specify a client which must receive the images.'
	exit 1
fi

CLIENT=$1
CLIENT_HOSTNAME=$(ssh StrictHostKeyChecking=false "${CLIENT}" hostname)
echo "Copying images to ${CLIENT_HOSTNAME}"


dd if="/dev/sda1" bs=1024k | \
	pigz -c -b2048 | \
	ssh StrictHostKeyChecking=false "${CLIENT}" \
	"pigz -dc -b2048 | dd bs=1024k of=/dev/sda1 status=progress"

ssh StrictHostKeyChecking=false "${CLIENT}" \
	'fsck -f "/dev/sda1"'

# The clone server has an extra partition between the
# linux detination partition and the mac partitions
# so it can host a minified mac partition

dd if="/dev/sda5" bs=1024k | \
	pigz -c -b2048 | \
	ssh StrictHostKeyChecking=false "${CLIENT}" \
	"pigz -dc -b2048 | dd bs=1024k of=/dev/sda4 status=progress"

ssh StrictHostKeyChecking=false "${CLIENT}" \
	'fsck -f "/dev/sda4"'


dd if="/dev/sda6" bs=1024k | \
	pigz -c -b2048 | \
	ssh StrictHostKeyChecking=false "${CLIENT}" \
	"pigz -dc -b2048 | dd bs=1024k of=/dev/sda5 status=progress"

ssh StrictHostKeyChecking=false "${CLIENT}" \
	'fsck -f "/dev/sda5"'
