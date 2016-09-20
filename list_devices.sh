#!/bin/bash
# 
# http://unix.stackexchange.com/questions/144029/
# command-to-determine-ports-of-a-device-like-dev-ttyusb0
#
# Determine ports of a device (like /dev/ttyUSB1)
#

for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
    (
        syspath="${sysdevpath%/dev}"
        devname="$(udevadm info -q name -p $syspath)"
        [[ "$devname" == "bus/"* ]] && continue
        eval "$(udevadm info -q property --export -p $syspath)"
        [[ -z "$ID_SERIAL" ]] && continue
        echo "/dev/$devname - $ID_SERIAL"
    )
done
