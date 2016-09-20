#!/bin/bash
#
#
# Upload bitalino (breadboard) firmware
# using arduino as a programmer (Arduino ISP)
#

AVRDUDE="/home/zekaf/Code/arduino-1.6.5/hardware/tools/avr/bin/avrdude" # avrdude
CONFIG_FILE="/home/zekaf/Code/arduino-1.6.5/hardware/tools/avr/etc/avrdude.conf" # configuration
HEX_FILE="main.hex"				# hex file
LOW="0xFF"						# Low Fuse
HIGH="0xDF"						# High Fuse
EXTENDED="0x05"					# Extended Fuse
PARTNO="m328p"					# AVR device(MCU)
PROGRAMMER="avrispmkII"			# AVR programmer
PORT="usb"						# Connection Port

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
CMD1="${AVRDUDE} \
-p ${PARTNO} \
-C ${CONFIG_FILE} \
-c ${PROGRAMMER} \
-P ${PORT} \
-U efuse:w:${EXTENDED}:m \
-U hfuse:w:${HIGH}:m \
-U lfuse:w:${LOW}:m \
-b 19200 \
-u -v"


# burn hex file
CMD2="sudo ${AVRDUDE} \
-p ${PARTNO} \
-C ${CONFIG_FILE} \
-P ${PORT} \
-c ${PROGRAMMER} \
-U flash:w:${HEX_FILE} \
-b 19200 \
-B 5 -v"

eval $CMD1 &&
eval $CMD2

