#!/bin/bash

cd $(readlink -f $(dirname ${BASH_SOURCE[0]}))

set -x

for script in *.cmd; do
	mkimage -T script -C none -d "$script" "${script%.cmd}.scr"
done
