#!/bin/bash
###############################################################################
#
# Script to upload bitalino firmware
# using Arduino UNO as a programmer (Arduino ISP)
#
# Requires:
# - Arduino UNO
# - AVRDUDE / Arduino IDE 
# - GNU linux operating system
# - curl and a working internet connection for HTTP fetches
#
# The following variables affect the behavior of this script:
# ARDUINO_IDE_PATH; Arduino IDE path
# AVRDUDE; avrdude binary path
# CONFIG_FILE; avrdude configuration path
# PARTNO; AVR device(MCU)
# PROGRAMMER - AVR programmer
# PORT; Connection Port
# HEX_FILE; hex file
# URL; URL location of hex file
# LOW; Low fuse
# HIGH; High fuse
# EXTENDED; Extended Fuse
# 
# 1 - Install Arduino IDE on user home directory
# https://www.arduino.cc/en/main/software
# 
# 2 - Use Arduino UNO as an AVR ISP
# https://www.arduino.cc/en/Tutorial/ArduinoISP
#  
# 3 - Run script using Arduino UNO port as argument (e.g. /dev/ttyUSB0)
#
#
# Authors: 
# Jose G. Faisca <jose.faisca@gmail.com>
#
# Version: 1.0
# Date: 08-2015
#
###############################################################################

ARDUINO_IDE_PATH="$HOME/Code/arduino-*"
AVRDUDE="${ARDUINO_IDE_PATH}/\
hardware/tools/avr/bin/avrdude"				
CONFIG_FILE="${ARDUINO_IDE_PATH}/\
hardware/tools/avr/etc/avrdude.conf"
PARTNO="m328p"
PROGRAMMER="stk500v1"
PORT="$1"
HEX_FILE="main.hex"
URL="https://raw.githubusercontent.com/BITalinoWorld/\
firmware-bitalino/master/prebuilt/"
LOW="0xFF"
HIGH="0xDF"
EXTENDED="0x05"

# find usb devices
function find_usb(){
  for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
	(
        syspath="${sysdevpath%/dev}"
        devname="$(udevadm info -q name -p $syspath)"
        [[ "$devname" == "bus/"* ]] && continue
        eval "$(udevadm info -q property --export -p $syspath)"
        [[ -z "$ID_SERIAL" ]] && continue
        device=$(echo "/dev/$devname - $ID_SERIAL" | grep tty)
        if [ -n "$device" ]; then
			echo $device
		fi
    )
  done
}

# check arguments
if [[ $# -ne 1 ]] ; then
	SCRIPT_NAME=$(basename "$0")
    echo "Usage: $SCRIPT_NAME <PORT>"
    echo "Available USB devices ..."
    find_usb
    exit 1
fi

# download hex file
if [ ! -f ${HEX_FILE} ]; then
    # hex file not found
    echo "download hex file ..."
    curl -O ${URL}${HEX_FILE}
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

# write hex file
CMD2="${AVRDUDE} \
-p ${PARTNO} \
-C ${CONFIG_FILE} \
-P ${PORT} \
-c ${PROGRAMMER} \
-U flash:w:${HEX_FILE} \
-b 19200 \
-B 5 -v"

eval $CMD1 &&
eval $CMD2

exit 0

