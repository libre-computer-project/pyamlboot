PLATFORM_GXL="gxl"
PLATFORM_G12="g12"

declare -A BOARD_GXL=(
	[aml-s805x-ac]="aml-s805x-ac"
	[aml-s805x-ac-v2]="aml-s805x-ac-v2"
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

board_is_supported(){
	[[ ! -v "BOARD_GXL[$1]" ]] || [[ ! -v "BOARD_G12[$1]" ]]
}

board_check(){
	if ! board_is_supported "$1"; then
		echo "Board $1 is not supported." >&2
		exit 1
	fi
}
