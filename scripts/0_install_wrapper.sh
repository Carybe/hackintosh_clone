#!/bin/bash -xe

if [ $# -lt 1 ]
then
        echo 'You must specify a host from which will receive the images.'
        exit 1
fi

HOST=$1
HOST_HOSTNAME=$(ssh -o StrictHostKeyChecking=false "${HOST}" hostname)
echo "Copying images from ${HOST_HOSTNAME}"

/scripts/1_*
/scripts/2_pull* "${HOST}"
/scripts/3_*
/scripts/4_*
