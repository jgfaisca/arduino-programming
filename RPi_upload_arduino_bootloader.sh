#!/bin/bash
#
# Using Raspberry Pi to Upload arduino bootloader
# https://learn.adafruit.com/program-an-avr-or-arduino-using-raspberry-pi-gpio-pins
#
# NOTE: Change the -c option if you use a different programmer 
#
# Authors:
#
# Jose G. Faisca <jose.faisca@gmail.com>
#

HEX_FILE="optiboot_atmega328.hex"	# hex file
LOW="0xFF"							# Low Fuse
HIGH="0xDE"							# High Fuse
EXTENDED="0x05"						# Extended Fuse
CONFIG_FILE="avrdude_gpio.conf" 	# location of configuration file
PARTNO="m328p"						# AVR device(MCU)
PROGRAMMER="pi_1"					# AVR programmer

# URL location of hex file
URL="https://github.com/arduino/Arduino/blob/\
master/hardware/arduino/avr/bootloaders/optiboot/"

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
-U lock:w:0x3f:m \
-U efuse:w:${EXTENDED}:m \
-U hfuse:w:${HIGH}:m \
-U lfuse:w:${LOW}:m \
-e -u -v"

eval $CMD

# burn bootloader, and set lock bits to lock bootloader section
CMD="sudo avrdude \
-p ${PARTNO} \
-C ${CONFIG_FILE} \
-c ${PROGRAMMER} \
-U flash:w:${HEX_FILE} \
-U lock:w:0x0f:m \
-v"

eval $CMD
