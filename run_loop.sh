#!/bin/bash

cd $(readlink -f $(dirname ${BASH_SOURCE[0]}))

. board.sh

if [ -z "$@" ]; then
	echo "$0 [options] # use same options as run.sh"
	exit 1
fi

board_check "$1"

set -e
export firmware=$(mktemp)
trap "rm \"$firmware\"" EXIT
wget -O "$firmware" "https://boot.libre.computer/ci/$1"
set +e

while true; do
	./run.sh $@
	ret=$?
	if [ $ret -ne 0 ]; then
		echo -e "\nLOOP: last run exited with $ret."
		sleep 5
	fi
done
