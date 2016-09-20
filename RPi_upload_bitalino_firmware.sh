#!/bin/bash
#
# Using Raspberry Pi to upload firmware
# https://learn.adafruit.com/program-an-avr-or-arduino-using-raspberry-pi-gpio-pins
#
# Upload bitalino firmware
#
# NOTE: Change the -c option if you use a different programmer 
#
# Authors:
#
# Jose G. Faisca <jose.faisca@gmail.com>
#



HEX_FILE="main.hex"					# hex file
LOW="0xFF"							# Low Fuse
HIGH="0xDF"							# High Fuse
EXTENDED="0x05"						# Extended Fuse
CONFIG_FILE="avrdude_gpio.conf" 	# location of configuration file
PARTNO="m328p"						# AVR device(MCU)
PROGRAMMER="pi_1"					# AVR programmer

# URL location of hex file
URL="https://github.com/BITalinoWorld/\
firmware-bitalino/blob/master/prebuilt/"

# install wget
if ! which wget > /dev/null; then
    echo "installing wget ..."
    sudo apt-get -y install wget
fi

# download hex file
if [ ! -f ${HEX_FILE} ]; then
    # hex file not found
    echo "download hex file ..."
    wget ${URL}${HEX_FILE}
fi

# set fuses and lock bits 
CMD="sudo avrdude \
-p ${PARTNO} \
-C ${CONFIG_FILE} \
-c ${PROGRAMMER} \
-U lock:w:0xFF:m \
-U efuse:w:${EXTENDED}:m \
-U hfuse:w:${HIGH}:m \
-U lfuse:w:${LOW}:m \
-e -u -v"

eval $CMD

# burn hex file
CMD="sudo avrdude \
-p ${PARTNO} \
-C ${CONFIG_FILE} \
-c ${PROGRAMMER} \
-U flash:w:${HEX_FILE} \
-B 5 -v"

eval $CMD
