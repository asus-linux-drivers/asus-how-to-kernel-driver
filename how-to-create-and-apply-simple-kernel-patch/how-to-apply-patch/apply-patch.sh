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

# drivers/platform/x86/asus-wmi.c
wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/drivers/platform/x86/asus-wmi.c?h=linux-$VERSION.y" -O 'drivers/platform/x86/asus-wmi.c'
# include/linux/platform_data/x86/asus-wmi.h
wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/include/linux/platform_data/x86/asus-wmi.h?h=linux-$VERSION.y" -O 'include/linux/platform_data/x86/asus-wmi.h'

patch -p1 < $PATCHFILE
rm *.orig
