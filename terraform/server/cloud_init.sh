#!/bin/bash

START=$(parted /dev/vda unit s print free | grep 'Free Space' | tail -n 1 | awk {'print $1'})
parted -a optimal -s /dev/vda mkpart primary $START 100%
sed -i -e s/"preserve_hostname: false"/"preserve_hostname: true"/g /etc/cloud/cloud.cfg
echo $HOSTNAME > /etc/hostname
chage -I -1 -m 0 -M 99999 -E -1 root
