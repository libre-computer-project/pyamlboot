#!/bin/bash

set -x

if [ -z "$1" ]; then
	echo "$0 PATH_TO_FILES"
	exit 1
fi

cd files

gxl_boards="aml-s805x-ac aml-s805x-ac-v2 aml-s905x-cc aml-s905x-cc-v2 aml-s905d-pc"
for gxl_b in $gxl_boards; do cp $1/$gxl_b.usb.tpl $gxl_b/u-boot.bin.usb.tpl; done
for gxl_b in $gxl_boards; do cp $1/$gxl_b.usb.bl2 $gxl_b/u-boot.bin.usb.bl2; done

g12_boards="aml-s905d3-cc aml-s095d3-cm aml-a311d-cc aml-a311d-cm"
for g12_b in $g12_boards; do cp $1/$g12_b $gxl_b/u-boot.bin; done
