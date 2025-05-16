#!/bin/bash

DEVICE=0bda:8152

echo "USB reload usbreset"
sleep 5
echo "usbreset two times ${DEVICE}"
sudo usbreset ${DEVICE}
sleep 5
sudo usbreset ${DEVICE}
usbreset
