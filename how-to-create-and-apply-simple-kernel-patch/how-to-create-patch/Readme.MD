# How to create patch

- Check the current kernel version

```
$ uname -r
6.2.0-37-generic
```

- Download the currently installed kernel version

```
$ wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.2.tar.xz
$ tar -xf linux-6.2.tar.xz
$ mv linux-6.2 linux-6.2-origin
$ cp -r linux-6.2-origin linux-6.2-patch
```

- Change code, for example:

 - `sudo gedit /include/linux/platform_data/x86/asus-wmi.h`
```
 #define ASUS_WMI_DEVID_CAMERA_LED 0x00060079
```

 - `sudo gedit  /drivers/platform/x86/asus-wmi.c`

```
# duplicated code for new camera led as has been already added for mic-mute led
```

- Constants and code in generally standardly defined in `include/` directory that is necessary for DKMS build include manually from own header file because headers inside `include/` are private ones and are applyied only when is build entire kernel so when is build part of kernel like DKMS will do for aplying this patch is necessary do it manually in own `.h` and `.c` file:

```
$ sudo gedit /drivers/platform/x86/include/asus-wmi.h
```

and content in `.h`

```
/* SPDX-License-Identifier: GPL-2.0 */
#ifndef __PLATFORM_DATA_X86_ASUS_WMI_H_EXT
#define __PLATFORM_DATA_X86_ASUS_WMI_H_EXT

#define ASUS_WMI_DEVID_CAMERA_LED		0x00060079

#endif	/* __PLATFORM_DATA_X86_ASUS_WMI_H_EXT */
```

and include in `.c`

```
#include "include/asus-wmi.h"
```

- Create the patch

```
$ diff -urpN linux-6.2-origin linux-6.2-patch > ../how-to-apply-patch/patch-6.2.patch
```

```
diff -urpN linux-6.2-origin/drivers/platform/x86/asus-wmi.c linux-6.2-patch/drivers/platform/x86/asus-wmi.c
--- linux-6.2-origin/drivers/platform/x86/asus-wmi.c	2023-02-19 23:24:22.000000000 +0100
+++ linux-6.2-patch/drivers/platform/x86/asus-wmi.c	2023-12-13 17:17:26.906766314 +0100
@@ -29,6 +29,7 @@
 #include <linux/pci.h>
 #include <linux/pci_hotplug.h>
 #include <linux/platform_data/x86/asus-wmi.h>
+#include "include/asus-wmi.h"
 #include <linux/platform_device.h>
 #include <linux/platform_profile.h>
 #include <linux/power_supply.h>
@@ -211,6 +212,7 @@ struct asus_wmi {
 	struct led_classdev lightbar_led;
 	int lightbar_led_wk;
 	struct led_classdev micmute_led;
+	struct led_classdev camera_led;
 	struct workqueue_struct *led_workqueue;
 	struct work_struct tpd_led_work;
 	struct work_struct wlan_led_work;
@@ -1153,6 +1155,17 @@ static int micmute_led_set(struct led_cl
 	return err < 0 ? err : 0;
 }
 
+static int camera_led_set(struct led_classdev *led_cdev,
+			   enum led_brightness brightness)
+{
+	int state = brightness != LED_OFF;
+	int err;
+
+	err = asus_wmi_set_devstate(ASUS_WMI_DEVID_CAMERA_LED, state, NULL);
+	return err < 0 ? err : 0;
+}
+
+
 static void asus_wmi_led_exit(struct asus_wmi *asus)
 {
 	led_classdev_unregister(&asus->kbd_led);
@@ -1160,6 +1173,7 @@ static void asus_wmi_led_exit(struct asu
 	led_classdev_unregister(&asus->wlan_led);
 	led_classdev_unregister(&asus->lightbar_led);
 	led_classdev_unregister(&asus->micmute_led);
+	led_classdev_unregister(&asus->camera_led);
 
 	if (asus->led_workqueue)
 		destroy_workqueue(asus->led_workqueue);
@@ -1251,6 +1265,17 @@ static int asus_wmi_led_init(struct asus
 		if (rv)
 			goto error;
 	}
+
+	if (asus_wmi_dev_is_present(asus, ASUS_WMI_DEVID_CAMERA_LED)) {
+		asus->camera_led.name = "platform::camera";
+		asus->camera_led.max_brightness = 1;
+		asus->camera_led.brightness_set_blocking = camera_led_set;
+
+		rv = led_classdev_register(&asus->platform_device->dev,
+						&asus->camera_led);
+		if (rv)
+			goto error;
+	}
 
 error:
 	if (rv)
diff -urpN linux-6.2-origin/drivers/platform/x86/include/asus-wmi.h linux-6.2-patch/drivers/platform/x86/include/asus-wmi.h
--- linux-6.2-origin/drivers/platform/x86/include/asus-wmi.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-6.2-patch/drivers/platform/x86/include/asus-wmi.h	2023-12-13 17:08:41.195162476 +0100
@@ -0,0 +1,13 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
+#ifndef __PLATFORM_DATA_X86_ASUS_WMI_H_EXT
+
+#define __PLATFORM_DATA_X86_ASUS_WMI_H_EXT
+
+
+
+#define ASUS_WMI_DEVID_CAMERA_LED		0x00060079
+
+
+
+#endif	/* __PLATFORM_DATA_X86_ASUS_WMI_H_EXT */
```

