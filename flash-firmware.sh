#!/bin/bash
if [ -z "$1" ]; then
	echo "Please specify a board name."
	exit 1
fi
SOURCE_DIR=$(readlink -f $(dirname ${BASH_SOURCE[0]}))
cd $SOURCE_DIR
if [ ! -d files/"$1" ]; then
	echo "Board does not exist!"
	exit 1
fi
FIRMWARE="`mktemp`"
if [ -z "$2" ]; then
	wget -O "$FIRMWARE" "http://share.loverpi.com/board/libre-computer-project/libre-computer-board/$1/firmware/latest.bin"
	if [ $? -ne 0 ]; then
		echo "Unable to download board firmware!"
		exit 1
	fi
elif [ -f "$2" ]; then
	cp "$2" "$FIRMWARE"
else
	echo "Firmware file does not exist!"
	exit 1
fi
FIRMWARE_SIZE=`stat --printf="%s" "$FIRMWARE"`
FIRMWARE_SIZE_BLOB="`mktemp`"
printf "%.8x" $FIRMWARE_SIZE | fold -w 2 | tac | tr -d "\n" | nl -s ": " -v 0 -w 1 | xxd -r > "$FIRMWARE_SIZE_BLOB"
sudo ./boot.py --script flash-firmware.scr --fdt "$FIRMWARE_SIZE_BLOB" --ramfs "$FIRMWARE" "$1"
if [ $? -eq 0 ]; then
	echo "Firmware updater push to board. Check board for flashing status."
else
	echo "Unable to push firmware updater to board."
fi
rm "$FIRMWARE" "$FIRMWARE_SIZE_BLOB"
