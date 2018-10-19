#!/bin/bash -xe

if [ $UID -ne 0 ]
then
	echo "This script must be run as root" >&2
	exit 1
fi

apple2linux_mac()
{
	echo $1 | tr [[:lower:]] [[:upper:]] | tr '-' ':'
}

linux2apple_mac()
{
	echo $1 | tr [[:upper:]] [[:lower:]] | tr ':' '-'
}

#mount /dev/sda2 /mnt

#trap 'cd /; umount /mnt' ERR EXIT

ACTIVE_BLUETOOTH_IF=$(hcitool  dev  | tail -n +2 | tr '\t' ' '| cut -d' ' -f3)
BLUETOOTH_KEY_FILE="/mnt/Users/numec/Desktop/bluetooth.keys"
if ! [ -f "${BLUETOOTH_KEY_FILE}" ]
then
	echo "Unable to find given file with the bluetooth keys." >&2
	exit 1
fi

# Removes inactive bluetooth interface configurations
for dev in $(ls /var/lib/bluetooth | grep -v "${ACTIVE_BLUETOOTH_IF}")
do
	rm -rf /var/lib/bluetooth/"${dev}"
done

cd /var/lib/bluetooth/*/ || ( echo "This script works only for single Bluetooth adapters" >&2 && exit 1 )


APPLE_MACS=$(grep \< "${BLUETOOTH_KEY_FILE}" | tr -d ' ' | cut -d'=' -f1 | tr -d '"')
LINUX_MACS="$(for i in ${APPLE_MACS}; do apple2linux_mac $i; done)"

#MOUSE_MAC=$(echo "${APPLE_MACS}" | grep -i f1)
#KEYBOARD_MAC=$(echo "${APPLE_MACS}" | grep -iv f1)

MOUSE_MAC=$(echo "${APPLE_MACS}" | grep -iv b8.f6)
KEYBOARD_MAC=$(echo "${APPLE_MACS}" | grep -i b8.f6)

#MOUSE_MAC=$(echo "${APPLE_MACS}" | grep -i 8c.ed)
#KEYBOARD_MAC=$(echo "${APPLE_MACS}" | grep -iv 8c-ed)

if [ $(echo "${MOUSE_MAC}" | wc -l) -gt 1 ]
then
	echo "Because of interface name restrictions its only possible to configure a single bluetooth mouse to this computer. There are more than one defined in ${BLUETOOTH_KEY_FILE}"
	exit 1
fi

if [ $(echo "${KEYBOARD_MAC}" | wc -l) -gt 1 ]
then
	echo "Because of interface name restrictions its only possible to configure a single bluetooth keyboard to this computer. There are more than one defined in ${BLUETOOTH_KEY_FILE}"
	exit 1
fi

# Setup mouse
LINUX_MAC=$(apple2linux_mac "${MOUSE_MAC}")
mkdir -p "${LINUX_MAC}"
KEY=$(grep "${MOUSE_MAC}" "${BLUETOOTH_KEY_FILE}" | cut -d '=' -f2 | tr -d '<>;' | sed 's/ //g;s/../\U&\n/g' | tac | tr -d '\n')

cat <<EOF > "${LINUX_MAC}"/info
[General]
Name=M_${HOSTNAME}
Class=0x002580
SupportedTechnologies=BR/EDR;
Trusted=true
Blocked=false
Services=00001124-0000-1000-8000-00805f9b34fb;00001200-0000-1000-8000-00805f9b34fb;

[LinkKey]
Key=${KEY}
Type=0
PINLength=0

[DeviceID]
Source=2
Vendor=1452
Product=781
Version=774

EOF

# Setup keyboard
LINUX_MAC=$(apple2linux_mac "${KEYBOARD_MAC}")
mkdir -p "${LINUX_MAC}"
KEY=$(grep "${KEYBOARD_MAC}" "${BLUETOOTH_KEY_FILE}" | cut -d '=' -f2 | tr -d '<>;' | sed 's/ //g;s/../\U&\n/g' | tac | tr -d '\n')

cat <<EOF > "${LINUX_MAC}"/info
[General]
Name=T_${HOSTNAME}
Class=0x002540
SupportedTechnologies=BR/EDR;
Trusted=true
Blocked=false
Services=00001124-0000-1000-8000-00805f9b34fb;00001200-0000-1000-8000-00805f9b34fb;

[LinkKey]
Key=${KEY}
Type=0
PINLength=0

[DeviceID]
Source=2
Vendor=1452
Product=597
Version=80

EOF

