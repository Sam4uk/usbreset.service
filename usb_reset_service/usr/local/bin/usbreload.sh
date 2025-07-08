#!/bin/bash

source /usr/local/etc/usb_reset_config.sh



echo "USB reload usbreset"
sleep 5

for DEVICE in "${DEVICE_LIST[@]}"; do
    echo "usbreset ${DEVICE}"
    sudo udevadm trigger --action=change --subsystem-match=usb \
    --attr-match idVendor=$(echo "$DEVICE" | awk '{print $1}') --attr-match idProduct=$(echo "$DEVICE" | awk '{print $2}')
    sleep 5
done


