#!/bin/bash
set -e

cd $(readlink -f $(dirname ${BASH_SOURCE[0]}))

AML_USB_ID="1b8e:c003"
LC_USB_ID="1b8e:fada"
if [ -z "$WAIT_TIME" ]; then
	WAIT_TIME=60
fi

. board.sh

if [ -z "$1" ]; then
	echo "$0 board firmware-update"
	echo "$0 board list"
	echo "$0 board [action]"
	exit 1
fi
board="${1,,}"

board_check "$board"

if ! python3 -c "import usb.core"; then
	echo "pyamlboot requires python3-usb"
	exit 1
fi

if [ ! -z "$2" ] && [ "$2" = "firmware-update" ]; then
	if ! which dfu-util; then
		echo "firmware-update requires dfu-util"
		exit 1
	fi
	if [ -z "$firmware" ]; then
		if [ "$board" = "aml-s905x-cc" ]; then
			read -n 1 -p "AML-S905X-CC does not have onboard firmware. This will update the eMMC/SD firmware. Press Control+C to cancel."
		fi
		firmware=$(mktemp)
		trap "rm \"$firmware\"" EXIT
		wget -O "$firmware" "https://boot.libre.computer/ci/$board"
	fi
fi

if [[ -v "BOARD_GXL[$board]" ]]; then
	platform=$PLATFORM_GXL
	if [ ! -z "$2" ] && [ "$2" != "firmware-update" ]; then
		if [ "$2" = "list" ]; then
			for script in scripts/*.scr; do
				if [ -h "$script" ]; then
					continue
				fi		
				echo "${script/scripts\//}" | sed "s/.scr\$//"
			done
			exit
		else
			if [ ! -f "scripts/$action.scr" ]; then
				echo "ACTION: $action does not exist." >&2
				exit 1
			fi
			action="--script \"scripts/$2.scr\""
		fi
	fi
elif [[ -v "BOARD_G12[$board]" ]]; then
	platform=$PLATFORM_G12
	if [ ! -z "$2" ] && [ "$2" != "firmware-update" ]; then
		echo "PLATFORM: $platform does not support actions." >&2
		exit 1
	fi
else
	echo "BOARD: $board does not exist."
	exit 1
fi

wait_time=0
while ! lsusb -d "$AML_USB_ID" > /dev/null 2>&1; do
	if [ "$wait_time" -eq 0 ]; then
		echo -n "Please plug in the board's OTG port with the USB/BOOT button held down."
		if [ "$WAIT_TIME" -ne 0 ]; then
			echo " Waiting for ${WAIT_TIME}s..."
		fi
	fi
	sleep 1
	wait_time=$((wait_time+1))
	echo -en "\rWaiting for device enumeration...${wait_time}s"
	if [ "$WAIT_TIME" -ne 0 ] && [ "$wait_time" = "$WAIT_TIME" ]; then
		echo -en "\nDevice could not be found after ${WAIT_TIME}s"
		exit 1
	fi
done

echo

if [ "$platform" = $PLATFORM_GXL ]; then
	./boot.py $action "${BOARD_GXL[$board]}"
else
	./boot-g12.py --board-name "${BOARD_G12[$board]}"
fi

if [ ! -z "$2" ] && [ "$2" = "firmware-update" ]; then
	dfu-util --device "$LC_USB_ID" -a 0 -w -D "$firmware"
fi

