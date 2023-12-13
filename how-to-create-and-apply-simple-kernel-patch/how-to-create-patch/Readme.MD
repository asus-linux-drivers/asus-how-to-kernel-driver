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

- Include headers standardly from include/ if necessary for build because headers inside include/ are private ones so when building part of kernel like DKMS does and using them have to be added manually in .h and .c file:

```
$ sudo gedit /drivers/platform/x86/include/asus-wmi.h
```

and content

```
/* SPDX-License-Identifier: GPL-2.0 */
#ifndef __PLATFORM_DATA_X86_ASUS_WMI_H_EXT
#define __PLATFORM_DATA_X86_ASUS_WMI_H_EXT

#define ASUS_WMI_DEVID_CAMERA_LED		0x00060079

#endif	/* __PLATFORM_DATA_X86_ASUS_WMI_H_EXT */
```

- Create the patch

```
$ diff -urpN linux-6.2-origin linux-6.2-patch > ../how-to-apply-patch/patch-6.2.patch
```

```
diff -urpN linux-6.2-origin/drivers/platform/x86/asus-wmi.c linux-6.2-patch/drivers/platform/x86/asus-wmi.c
--- linux-6.2-origin/drivers/platform/x86/asus-wmi.c	2023-02-19 23:24:22.000000000 +0100
+++ linux-6.2-patch/drivers/platform/x86/asus-wmi.c	2023-12-12 14:05:41.925958771 +0100
@@ -211,6 +211,7 @@ struct asus_wmi {
 	struct led_classdev lightbar_led;
 	int lightbar_led_wk;
 	struct led_classdev micmute_led;
+	struct led_classdev camera_led;
 	struct workqueue_struct *led_workqueue;
 	struct work_struct tpd_led_work;
 	struct work_struct wlan_led_work;
@@ -1153,6 +1154,16 @@ static int micmute_led_set(struct led_cl
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
 static void asus_wmi_led_exit(struct asus_wmi *asus)
 {
 	led_classdev_unregister(&asus->kbd_led);
@@ -1160,6 +1171,7 @@ static void asus_wmi_led_exit(struct asu
 	led_classdev_unregister(&asus->wlan_led);
 	led_classdev_unregister(&asus->lightbar_led);
 	led_classdev_unregister(&asus->micmute_led);
+	led_classdev_unregister(&asus->camera_led);

 	if (asus->led_workqueue)
 		destroy_workqueue(asus->led_workqueue);
@@ -1251,6 +1263,17 @@ static int asus_wmi_led_init(struct asus
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
diff -urpN linux-6.2-origin/include/linux/platform_data/x86/asus-wmi.h linux-6.2-patch/include/linux/platform_data/x86/asus-wmi.h
--- linux-6.2-origin/include/linux/platform_data/x86/asus-wmi.h	2023-02-19 23:24:22.000000000 +0100
+++ linux-6.2-patch/include/linux/platform_data/x86/asus-wmi.h	2023-12-12 14:08:52.358596576 +0100
@@ -50,6 +50,7 @@
 #define ASUS_WMI_DEVID_LED5		0x00020015
 #define ASUS_WMI_DEVID_LED6		0x00020016
 #define ASUS_WMI_DEVID_MICMUTE_LED		0x00040017
+#define ASUS_WMI_DEVID_CAMERA_LED		0x00060079

 /* Backlight and Brightness */
 #define ASUS_WMI_DEVID_ALS_ENABLE	0x00050001 /* Ambient Light Sensor */
```

