#!/bin/bash

set -e
set -u

# Datasheet for AXP209:
# http://linux-sunxi.org/AXP209#ADC_Measurement_Values

I2CGET=/usr/sbin/i2cget

I2C_BUS=0
CHIP_ADDRESS=0x34

function get_value_offset() {
	DATA_ADDRESS_HIGH=$1
	DATA_ADDRESS_LOW=$2
	SCALE=$3
	OFFSET=$4
	
	HIGH_8BITS=`$I2CGET -y -f $I2C_BUS $CHIP_ADDRESS $DATA_ADDRESS_HIGH`
	LOW_4BITS=`$I2CGET -y -f $I2C_BUS $CHIP_ADDRESS $DATA_ADDRESS_LOW`
	COMBINED_BITS=$(( ($HIGH_8BITS<<4) | $LOW_4BITS ))

	echo "scale=3; $OFFSET + $COMBINED_BITS * $SCALE" | bc
}

function get_value() {
	get_value_offset $1 $2 $3 0
}

COMMAND=${1:-USAGE}

case $COMMAND in
ACIN_VOLTAGE)
	# one step is 1.7 mV
	get_value 0x56 0x57 "1.7/1000"
	;;
ACIN_CURRENT)
	# one step is 0.625 mA
	get_value 0x58 0x59 "0.625/1000"
	;;
VBUS_VOLTAGE)
	get_value 0x5A 0x5B "1.7/1000"
	;;
VBUS_CURRENT)
	get_value 0x5C 0x5D "0.375/1000"
	;;
TEMPERATURE)
	get_value_offset 0x5E 0x5F "0.1" "-144.7"
	;;
*)
	echo "Usage: $0 COMMAND"
	echo "  Supported commands:"
	echo "    ACIN_VOLTAGE"
	echo "    ACIN_CURRENT"
	echo "    VBUS_VOLTAGE"
	echo "    VBUS_CURRENT"
	echo "    TEMPERATURE"
	exit 1
	;;
esac
