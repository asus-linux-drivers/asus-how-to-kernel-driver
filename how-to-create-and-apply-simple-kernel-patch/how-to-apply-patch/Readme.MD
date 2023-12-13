# How to apply patch (using DKMS)
 
- Check the current kernel version
 
```
$ uname -r
6.2.0-37-generic
 
- Download files that patch changes
 
```
$ VERSION=6.2

# drivers/platform/x86/asus-wmi.c
$ mkdir -p drivers/platform/x86
$ wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/drivers/platform/x86/asus-wmi.c?h=linux-$VERSION.y" -O "drivers/platform/x86/asus-wmi.c"
# include/linux/platform_data/x86/asus-wmi.h
$ mkdir -p include/linux/platform_data/x86
$ wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/include/linux/platform_data/x86/asus-wmi.h?h=linux-$VERSION.y" -O "include/linux/platform_data/x86/asus-wmi.h"
```
 
- Apply patch on those files
 
```
$ patch -p1 < "patch-6.2.patch"
```
 
