#!/bin/bash

source /usr/local/etc/usb_reset_config.sh



echo "USB reload usbreset"
# sleep 5

for DEVICE in "${DEVICE_LIST[@]}"; do
    echo "usbreset two times ${DEVICE}"
    sleep 5
    sudo usbreset ${DEVICE}
    sleep 5
    sudo usbreset ${DEVICE}
done
usbreset

