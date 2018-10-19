#!/bin/bash -xe

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
