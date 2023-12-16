# How to apply patch (using DKMS)

- Install DKMS

```
$ sudo apt install dkms
```

- Check the current kernel version

```
$ uname -r
6.2.0-37-generic
```

- Install current kernel version header files

```
$ sudo apt install linux-headers-6.2.0-37-generic
```

- Download files that patch changes for current kernel version (header files are required for build canonical .c even no changes are done inside of them)
 
```
$ VERSION=6.2

# drivers/platform/x86/asus-wmi.c
# drivers/platform/x86/asus-wmi.h
mkdir -p drivers/platform/x86
wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/drivers/platform/x86/asus-wmi.c?h=linux-$VERSION.y" -O "drivers/platform/x86/asus-wmi.c"
wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/drivers/platform/x86/asus-wmi.h?h=linux-$VERSION.y" -O "drivers/platform/x86/asus-wmi.c"

# include/linux/platform_data/x86/asus-wmi.h
mkdir -p include/linux/platform_data/x86
wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/include/linux/platform_data/x86/asus-wmi.h?h=linux-$VERSION.y" -O "include/linux/platform_data/x86/asus-wmi.h"
```
 
- Apply patch on those files
 
```
$ patch -p1 < "patch-6.2.patch"
```
 
- Copy patched files (DKMS module src folder)

```
$ sudo mkdir /usr/src/asus-wmi-1.0
$ sudo cp -r . /usr/src/asus-wmi-1.0
```

- Build and install DKMS module

```
$ sudo dkms remove -m asus-wmi -v 1.0 --all
$ sudo dkms build -m asus-wmi -v 1.0
$ sudo dkms install -m asus-wmi -v 1.0
```
