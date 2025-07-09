#!/bin/bash
#
cd $(readlink -f $(dirname ${BASH_SOURCE[0]}))

PLATFORM_GXL="gxl"
PLATFORM_G12="g12"

declare -A BOARD_GXL=(
	[aml-s805x-ac]="aml-s805x-ac"
	[aml-s905x-cc]="aml-s905x-cc"
	[aml-s905x-cc-v2]="aml-s905x-cc-v2"
	[aml-s905d-pc]="aml-s905d-pc"
	[aml-s912-pc]="aml-s912-pc"
	)
declare -A BOARD_G12=(
	[aml-s905d3-cc]="aml-s905d3-cc"
	[aml-s905d3-cc-v01]="aml-s905d3-cc-v01"
	[aml-a311d-cc]="aml-a311d-cc"
	[aml-a311d-cc-v01]="aml-a311d-cc-v01"
	)

if [ -z "$1" ]; then
	echo "$0 board firmware-update"
	echo "$0 board list"
	echo "$0 board [action]"
	exit 1
fi
board="$1"

if [ ! -z "$2" ] && [ "$2" = "firmware-update" ]; then
	if [ "$board" = "aml-s905x-cc" ]; then
		read -n 1 -p "AML-S905X-CC does not have onboard firmware. This will update the eMMC/SD firmware. Press Control+C to cancel."
	fi
	firmware=$(mktemp)
	trap "rm \"$firmware\"" EXIT
	wget -O "$firmware" "https://boot.libre.computer/ci/$board"
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

if [ "$platform" = $PLATFORM_GXL ]; then
	./boot.py $action "${BOARD_GXL[$board]}"
else
	./boot-g12.py --board-name "${BOARD_G12[$board]}"
fi

if [ ! -z "$2" ] && [ "$2" = "firmware-update" ]; then
	dfu-util --device 1b8e:fada -a 0 -w -D "$firmware"
fi

