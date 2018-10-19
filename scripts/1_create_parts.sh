#!/bin/bash -xe

DIR=$(realpath $(dirname $0))

source "${DIR}"/def

# Expected Partition Table is something like this:
#/dev/disk0 (internal, physical):
#   #:                       TYPE NAME                    SIZE       IDENTIFIER
#   0:      GUID_partition_scheme                        *500.1 GB   disk0
#   1:                        EFI EFI                     209.7 MB   disk0s1
#   2:                  Apple_HFS Macintosh HD            340.0 GB   disk0s2
#   3:                 Apple_Boot Recovery HD             650.0 MB   disk0s3
#   4:                  Apple_HFS Untitled                159.1 GB   disk0s4

### Checks if the table is equally partitioned to the expected

if ! echo "${TABLE_STATUS}" | grep sda1 | grep --quiet EFI
then
	echo "Theres something wrong, the first partition should be a EFI System"
	exit 1
fi

if ! echo "${TABLE_STATUS}" | grep sda2 | grep --quiet HFS
then
	echo "Theres something wrong, the second partition should be a HFS partition."
	exit 1
fi

if ! echo "${TABLE_STATUS}" | grep sda3 | grep --quiet boot
then
	echo "Theres something wrong, the third partition should be an Apple-boot partition."
	exit 1
fi

if echo "${TABLE_STATUS}" | grep --quiet sda[5-9]
then
	echo "Theres something wrong, this system has more partitions than the expected, see the source of this script for more info."
	exit 1
fi

# Overly specific check for 1st iteration
#if ! echo "${TABLE_STATUS}" | grep sda |grep --quiet $FULL_SECTOR_COUNT
#then
#	echo "Theres something wrong, the disk has a different amount of sectors than the expected."
#	exit 2
#fi


### Checks if the free partition was created right
if [ $FREE_SPACE -lt $FULLSIZE ]
then
	echo "Theres something wrong, the Apple Boot partition is taking space that should be used by linux partition."
	exit 2
fi

# Start the partitioning!

if echo "${TABLE_STATUS}" | grep --quiet sda4
then
	parted --script --align=opt /dev/sda rm 4
fi

parted --script --align=opt /dev/sda mkpart root ext4 "${ROOT_S}"s "${ROOT_F}"s
parted --script --align=opt /dev/sda mkpart home ext4 "${HOME_S}"s "${HOME_F}"s
parted --script --align=opt /dev/sda mkpart swap ext4 "${SWAP_S}"s 100%
