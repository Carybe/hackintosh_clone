#!/bin/bash -e

# Script to shrink a given ext partition to its smallest size:

if [ $# -lt 1 ]
then
        echo 'You must specify a partition you want to shrink.'
        exit 1
fi

# Ex: '/dev/sda1'
PARTITION=$1

# Partition start sector
PARTITION_S=$(fdisk -l | grep $PARTITION | tr -s ' ' | cut -d' ' -f2)

DISK=${PARTITION%%[1-9]*}
PARTITION_NUMBER=${PARTITION##$DISK}

# Pre-check and fix the partition
e2fsck -fDp $PARTITION || true
e2fsck -fDy $PARTITION || true
e2fsck -f $PARTITION

INIT_BLOCK_COUNT=$(dumpe2fs $PARTITION 2> /dev/null| grep '^Block count'| tr -s ' ' | cut -d' ' -f 3)
OLD_BLOCK_COUNT=$INIT_BLOCK_COUNT

BLOCK_SIZE=$(dumpe2fs $PARTITION 2> /dev/null| grep '^Block size'| tr -s ' ' | cut -d' ' -f 3)
SECTOR_SIZE=$(blockdev --getpbsz $PARTITION)

RATIO=$(( BLOCK_SIZE / SECTOR_SIZE ))

# Resize partition to its initial minimal size
resize2fs $PARTITION -Mp
BLOCK_COUNT=$(dumpe2fs $PARTITION 2> /dev/null| grep '^Block count'| tr -s ' ' | cut -d' ' -f 3)

# Rerun the resize to get the minimal possible size since every iteration
# the environment changes
while [ $BLOCK_COUNT -lt $OLD_BLOCK_COUNT ]
do
	OLD_BLOCK_COUNT=$BLOCK_COUNT
	resize2fs $PARTITION -Mp
	BLOCK_COUNT=$(dumpe2fs $PARTITION 2> /dev/null| grep '^Block count'| tr -s ' ' | cut -d' ' -f 3)
done

# Only tries to logically resize it if it was physically resized
if [ $BLOCK_COUNT -lt $INIT_BLOCK_COUNT ]
then
	parted ---pretend-input-tty --align=opt $DISK resizepart $PARTITION_NUMBER $(( PARTITION_S + ((BLOCK_COUNT) * RATIO) ))s Yes
fi

sync -f
partprobe

# Wait 5 seconds to be sure that the partition table will be updated
sleep 5

# Recheck ann fix the partition
e2fsck -vfDp $PARTITION || true
e2fsck -vfDy $PARTITION || true

exit 0
