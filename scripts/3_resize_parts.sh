#!/bin/bash -xe

# Resize the hosts shrunk partitions to fit the available space between partitions

DIR=$(realpath $(dirname $0))

source "${DIR}"/def

parted --script --align=opt /dev/sda resizepart 4 $(( ROOT_S + ROOT_fullsize - 1 ))s
parted --script --align=opt /dev/sda resizepart 5 $(( HOME_S + HOME_fullsize - 1))s

sync -f
partprobe
sleep 5

resize2fs -p /dev/sda4 "${ROOT_fullsize}"s
resize2fs -p /dev/sda5 "${HOME_fullsize}"s

sync -f
partprobe
sleep 5

e2fsck -vfDp /dev/sda4 || true
e2fsck -vfDy /dev/sda4 || true

e2fsck -vfDp /dev/sda5 || true
e2fsck -vfDy /dev/sda5 || true
