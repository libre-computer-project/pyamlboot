#!/bin/bash

if [ -z "$1" ]; then
	echo "$0 PATH_TO_FILES [BOARD]"
	exit 1
fi

board=
if [ ! -z "$2" ]; then
	board="$2"
fi

cd $(readlink -f $(dirname ${BASH_SOURCE[0]}))

set -x

gxl_boards=(
	aml-s805x-ac
	aml-s805x-ac-v2
	aml-s905x-cc
	aml-s905x-cc-v2
)
for gxl_b in ${gxl_boards[@]}; do
	if [ ! -z "$board" ] && [ "$board" != "$gxl_b" ]; then
		continue
	fi
	cp $1/$gxl_b.usb.tpl $gxl_b/u-boot.bin.usb.tpl
done
for gxl_b in ${gxl_boards[@]}; do 
	if [ ! -z "$board" ] && [ "$board" != "$gxl_b" ]; then
		continue
	fi
	cp $1/$gxl_b.usb.bl2 $gxl_b/u-boot.bin.usb.bl2
done

g12_boards=(
	aml-s905d3-cc
	aml-a311d-cc
)
for g12_b in ${g12_boards[@]}; do
	if [ ! -z "$board" ] && [ "$board" != "$gxl_b" ]; then
		continue
	fi
	cp $1/$g12_b $g12_b/u-boot.bin
done
