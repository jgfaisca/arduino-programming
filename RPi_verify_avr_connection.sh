#!/bin/bash
#
#
# Verify connection to AVR device
# 
# NOTE: Change the -c option if your programmer is not an raspberry pi 
#
# Authors:
#
# Jose G. Faisca <jose.faisca@gmail.com>
#


CONFIG_FILE="avrdude_gpio.conf" 	# location of configuration file
PARTNO="m328p"						# AVR device(MCU)
PROGRAMMER="pi_1"					# AVR programmer

CMD="sudo avrdude \
-p ${PARTNO} \
-C ${CONFIG_FILE} \
-c ${PROGRAMMER} \
-v"

eval $CMD
