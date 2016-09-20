#!/bin/bash
#
#
# Verify connection to AVR device
# using arduino as a programmer (Arduino ISP)
# 
# NOTE: Change the -c option if you use a different programmer 
#

AVRDUDE="/home/zekaf/Code/arduino-1.6.5/hardware/tools/avr/bin/avrdude" # avrdude
CONFIG_FILE="/home/zekaf/Code/arduino-1.6.5/hardware/tools/avr/etc/avrdude.conf" # configuration
PARTNO="m328p"						# AVR device(MCU)
PROGRAMMER="avrispmkII"				# AVR programmer
PORT="usb"							# Connection Port

CMD="${AVRDUDE} \
-p ${PARTNO} \
-C ${CONFIG_FILE} \
-c ${PROGRAMMER} \
-P ${PORT} \
-b 19200 \
-v"

eval $CMD
