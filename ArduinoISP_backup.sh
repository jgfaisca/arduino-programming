#!/bin/bash
###############################################################################
#
# Script to backup a working AVR microcontroller firmware: 
# including bootloader, user programming, eeprom, and fuses, using 
# Arduino UNO as a programmer (Arduino ISP)
#
# Requires:
# - Arduino UNO
# - AVRDUDE / Arduino IDE 
# - GNU linux operating system
#
# The following variables affect the behavior of this script:
# ARDUINO_IDE_PATH; Arduino IDE path
# AVRDUDE; avrdude binary path
# CONFIG_FILE; avrdude configuration path
# PARTNO; AVR device(MCU)
# PROGRAMMER - AVR programmer
# PORT; Connection Port
# LOG_FILE; log file
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
# Jose Faisca <jose.faisca@gmail.com>
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
LOG_FILE="backup.log"

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

# ckeck arguments
if [[ $# -ne 1 ]] ; then
	SCRIPT_NAME=$(basename "$0")
    echo "Usage: $SCRIPT_NAME <PORT>"
    echo "Available USB devices ..."
    find_usb
    exit 1
fi

# read from avr and write backup file 
function read() { 
	BACKUP_FILE="backup_$1.hex" 		
	CMD="${AVRDUDE} \
	-p ${PARTNO} \
	-C ${CONFIG_FILE} \
	-c ${PROGRAMMER} \
	-P ${PORT} \
	-U $1:r:${BACKUP_FILE}:i \
	-b 19200 \
	-v"
	eval $CMD 	
}

# check backup file
function check_file(){
	BACKUP_FILE="backup_$1.hex"	
	if [ -f "$BACKUP_FILE" ]; then
		return 0 # true
	else
		return 1 # false
	fi
}

# backup 
function backup(){
	BACKUP_FILE="backup_$1.hex"	
	if read $1  &&  check_file $1; then
		echo "$1 has been saved to $BACKUP_FILE" >> $LOG_FILE
		return 0 # true
	else
		echo "$1 was not saved" >> $LOG_FILE
		return 1 # false
	fi	
}

# remove backup files
rm -rf $LOG_FILE
rm -rf backup_*

# create log file
touch $LOG_FILE

echo "BACKUP $PARTNO VIA Arduino ISP ON $PORT" >> $LOG_FILE
echo $(date '+%Y/%m/%d %H:%M:%S') >> $LOG_FILE

# backup flash
backup "flash"

# backup eeprom
backup "eeprom"

# backup hfuse
backup "hfuse"

# backup lfuse
backup "lfuse"

# backup efuse
backup "efuse"

# print log file
echo "################################################## "
cat "$LOG_FILE" 

exit 0
