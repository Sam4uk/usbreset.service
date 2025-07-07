#!/bin/bash

source /usr/local/etc/usb_reset_config.sh



echo "USB reload usbreset"
sleep 5

for DEVICE in "${DEVICE_LIST[@]}"; do
    echo "usbreset ${DEVICE}"
    sudo usbreset ${DEVICE}
    sleep 5
done
usbreset

