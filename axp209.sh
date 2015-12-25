#!/bin/bash

set -e
set -u

I2CGET=/usr/sbin/i2cget

I2C_BUS=0
CHIP_ADDRESS=0x34

ACIN_H=0x56
ACIN_L=0x57
# one step is 1.7 mV
ACIN_SCALE_V="1.7/1000"

function get_value() {
	DATA_ADDRESS_HIGH=$1
	DATA_ADDRESS_LOW=$2
	SCALE=$3

	HIGH_8BITS=`$I2CGET -y -f $I2C_BUS $CHIP_ADDRESS $DATA_ADDRESS_HIGH`
	LOW_4BITS=`$I2CGET -y -f $I2C_BUS $CHIP_ADDRESS $DATA_ADDRESS_LOW`
	COMBINED_BITS=$(( ($HIGH_8BITS<<4) | $LOW_4BITS ))

	echo "scale=3; $COMBINED_BITS * $SCALE" | bc
}

COMMAND=${1:-USAGE}

case $COMMAND in
ACIN)
	get_value $ACIN_H $ACIN_L $ACIN_SCALE_V
	;;
*)
	echo "Usage: $0 {ACIN}"
	exit 1
	;;
esac
