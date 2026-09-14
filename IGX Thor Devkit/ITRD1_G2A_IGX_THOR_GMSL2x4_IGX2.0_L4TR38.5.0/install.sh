#!/bin/bash

CONF_FILE="/boot/extlinux/extlinux.conf"
BACKUP_FILE="/boot/extlinux/extlinux.conf.bak"

if [ -f "$CONF_FILE" ]; then
    if [ ! -f "$BACKUP_FILE" ]; then
        sudo cp "$CONF_FILE" "$BACKUP_FILE"
        echo "Backup created: $BACKUP_FILE"
        # cp "$BACKUP_FILE" .
    else
        echo "Backup already exists. Skipping."
    fi
else
    echo "extlinux.conf does not exist. Cannot create backup."
fi

# update ko
sudo cp ko/tegra-camera.ko /lib/modules/6.8.12-1009-tegra/updates/drivers/media/platform/tegra/camera/
sudo cp ko/nvhost-nvcsi.ko /lib/modules/6.8.12-1009-tegra/updates/drivers/video/tegra/host/nvcsi/
sudo rm -rf /lib/modules/6.8.12-1009-tegra/updates/drivers/media/i2c/max96712.ko

# add dtbo
sudo cp dtb/SGCAM_GMSL2/*.dtbo /boot/

# upgrade Image
sudo cp boot/Image /boot/Image

sync
