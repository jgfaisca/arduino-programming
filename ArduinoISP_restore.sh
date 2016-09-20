#!/bin/bash
###############################################################################
#
# Script to restore a working AVR microcontroller firmware: 
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
LOG_FILE="restore.log"

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

# read from backup file and write to avr 
function write() { 
	BACKUP_FILE="backup_$1.hex" 		
	CMD="${AVRDUDE} \
	-p ${PARTNO} \
	-C ${CONFIG_FILE} \
	-c ${PROGRAMMER} \
	-P ${PORT} \
	-U $1:w:${BACKUP_FILE} \
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

# restore 
function restore(){
	BACKUP_FILE="backup_$1.hex"	
	if ! check_file $1; then 
		echo "$1 $BACKUP_FILE not found" >> $LOG_FILE
		return 1 # false
	fi
	
	if write $1; then
		echo "$1 $BACKUP_FILE writen" >> $LOG_FILE
		return 0 # true
	else
		echo "$1 was not writen" >> $LOG_FILE
		return 1 # false
	fi		
}

# remove log file
rm -rf $LOG_FILE

# create log file
touch $LOG_FILE

# create log title
echo "RESTORE $PARTNO VIA Arduino ISP ON $PORT" >> $LOG_FILE
echo "$(date '+%Y/%m/%d %H:%M:%S')" >> $LOG_FILE

# restore flash
restore "flash"

# restore eeprom
restore "eeprom"

# restore hfuse
restore "hfuse"

# restore lfuse
restore "lfuse"

# restore efuse
restore "efuse"

# print log file
echo "################################################## "
cat "$LOG_FILE" 

exit 0
