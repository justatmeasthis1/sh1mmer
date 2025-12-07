#!/bin/bash
set -e

# Run cgpt command
cgpt add /dev/mmcblk0 -i 2 -P 10 -T 5 -S 1

# Format partition 1
yes | mkfs.ext4 /dev/mmcblk0p1

# Run fdisk with scripted input
fdisk /dev/mmcblk0 <<EOF
d
4
d
5
w
EOF
