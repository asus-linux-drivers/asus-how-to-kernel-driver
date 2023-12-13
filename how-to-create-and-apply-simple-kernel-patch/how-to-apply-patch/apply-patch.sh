#!/bin/bash

VERSION=`uname -r | grep -o '^[0-9]\+\.[0-9]\+'`

if [[ "$VERSION" == "6.2" ]]
then
  PATCH_FILE="patch-6.2"
else
  echo "Kernel version: ${VERSION} is not supported"
  exit 0
fi

echo "Using: $PATCH_FILE"

rm -rf drivers

# drivers/platform/x86/asus-wmi.c
# drivers/platform/x86/asus-wmi.h
mkdir -p drivers/platform/x86
wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/drivers/platform/x86/asus-wmi.c?h=linux-$VERSION.y" -O "drivers/platform/x86/asus-wmi.c"
wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/drivers/platform/x86/asus-wmi.h?h=linux-$VERSION.y" -O "drivers/platform/x86/asus-wmi.h"

# headers inside include/ are private ones so when building part of kernel like DKMS does and using them file has to be added manually in .h and be included .c file
# (patch contains include with new path below)
mkdir -p drivers/platform/x86/include

patch -p1 < "${PATCH_FILE}.patch"

sudo mkdir -p /usr/src/asus-wmi-1.0
sudo cp -r . /usr/src/asus-wmi-1.0
