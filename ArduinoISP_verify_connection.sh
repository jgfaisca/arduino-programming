#!/bin/bash
###############################################################################
#
# Script to verify connection to AVR device
# using Arduino UNO as a programmer (Arduino ISP)
#
# Requires:
# - Arduino UNO
# - AVRDUDE / Arduino IDE 
# - GNU Linux operating system
# - Linux STTY
#
# The following variables affect the behavior of this script:
# ARDUINO_IDE_PATH; Arduino IDE path
# AVRDUDE; avrdude binary path
# CONFIG_FILE; avrdude configuration path
# PARTNO; AVR device(MCU)
# PROGRAMMER - AVR programmer
# PORT; Connection Port
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
			port=${device%% *}
			check_port $port
		fi
    )
  done
}

# check port
function check_port(){
	port=$1
	CMD0="stty -F ${port} cs8 115200 ignbrk -brkint \
	-icrnl imaxbel -opost -onlcr -isig -icanon \
	-iexten -echo -echoe -echok -echoctl -echoke \
	noflsh -ixon -crtscts"
	CMD1="stty -a -F ${port}"
	eval $CMD0 >/dev/null 2>&1
	eval $CMD1 >/dev/null 
    if [ $? -eq 0 ]; then 
		return 0 # true
	else
		echo "$(tput setaf 1)An error occurred trying to connect ${port} $(tput sgr0)"
		return 1 # false
	fi
}

# ckeck arguments
if [[ $# -ne 1 ]] ; then
	SCRIPT_NAME=$(basename "$0")
	echo "Usage: $SCRIPT_NAME <PORT>"
    echo "Available USB devices ..."
    find_usb
    exit 1
  else 
	if ! check_port $PORT; then 
		exit 1
	fi	 
fi

# try connection
CMD="${AVRDUDE} \
-p ${PARTNO} \
-C ${CONFIG_FILE} \
-c ${PROGRAMMER} \
-P ${PORT} \
-b 19200 \
-v"

echo $CMD
eval $CMD

exit 0
