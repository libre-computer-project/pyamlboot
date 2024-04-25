#!/bin/bash
#
cd $(readlink -f $(dirname ${BASH_SOURCE[0]}))

declare -A BOARD=(
	[aml-s805x-ac]="libretech-s805x-ac"
	[aml-s905x-cc]="libretech-s905x-cc"
	[aml-s905x-cc-v2]="libretech-s905x-cc-v2"
	[aml-s905d-pc]="libretech-s905d-pc"
	[aml-s912-pc]="libretech-s912-pc"
	[aml-s905d3-cc]="libreteech-s905d3-cc"
	[aml-s905d3-cc-v01]="libretech-s905d3-cc-v01"
	[aml-a311d-cc]="libreteech-a311d-cc"
	[aml-a311d-cc-v01]="libretech-a311d-cc-v01"
	)

if [ -z "$1" ]; then
	echo "$0 board action"
	exit 1
fi
board="$1"

if [[ ! -v "BOARD[$board]" ]]; then
	echo "BOARD: $board does not exist."
	exit 1
fi

if [ -z "$2" ]; then
	for script in scripts/*.scr; do
		if [ -h "$script" ]; then
			continue
		fi		
		echo "${script/scripts\//}" | sed "s/.scr\$//"
	done
	exit
fi
action="$2"

if [ ! -f "scripts/$action.scr" ]; then
	echo "SCRIPT: $action does not exist."
	exit 1
fi

./boot.py --script "scripts/$action.scr" "${BOARD[$board]}"
