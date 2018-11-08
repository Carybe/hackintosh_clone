#!/bin/bash -xe

# Script to make the necessary modifications in the system to either
# differentiate its environment or to fix minor problems that might arise
# from a duplicated system in the same network

# Copy macos scripts to its host
cp /tmp/scripts/get_bluetooth_keys.sh /mnt/Users/numec/Desktop

# BLUETOOTH
bluetoothd &
sleep 1
ACTIVE_BLUETOOTH_IF=$(hcitool  dev  | tail -n +2 | tr '\t' ' '| cut -d' ' -f3)
# Removes inactive bluetooth interface configurations
for dev in $(ls /var/lib/bluetooth | grep -v "${ACTIVE_BLUETOOTH_IF}")
do
	rm -rf /var/lib/bluetooth/"${dev}"
done

# Name of the computer:
NEW_HOSTNAME=$(grep -A1 '>ComputerName<' /mnt/Library/Preferences/SystemConfiguration/preferences.plist | tail -n1 | sed 's/.*<string>\([^<]\+\).*/\1/')
echo "${NEW_HOSTNAME}" | tr ' !@#$%^&*()+=`~";:/?>.<,' '_' > /etc/hostname

# Audio connector bug
# Details in: https://help.ubuntu.com/community/Intel_iMac#Sound
# Not sure if breaks differents versions of macs, so need to try these different options:
if lspci | grep -q Whistler
then
        echo 'options snd-hda-intel model=imac27_122' >> /etc/modprobe.d/alsa-base.conf
fi
#echo 'options snd-hda-intel model=auto' >> /etc/modprobe.d/alsa-base.conf
#echo 'options snd-hda-intel model=intel_mac_auto' >> /etc/modprobe.d/alsa-base.conf
#echo 'options snd-hda-intel model=imac27' >> /etc/modprobe.d/alsa-base.conf
#echo 'options snd-hda-intel model=imac27_122' >> /etc/modprobe.d/alsa-base.conf

#SWAP
SWAP_UUID='c51486df-09b3-41ea-be1c-cccc97f75f49'
mkswap --uuid="${SWAP_UUID}" /dev/sda6
swapon /dev/sda6

#GRUB
grub-install --target=x86_64-efi efi-directory=/boot/efi

#REFInd
refind-install
pushd /boot/efi/EFI
rm -rf refind
tar xzf refind.tar.gz
popd
