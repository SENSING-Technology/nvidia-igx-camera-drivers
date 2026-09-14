#!/bin/bash

# ==========================================
# 权限检查：脚本一启动就检查，防止执行一半因权限失败导致系统状态异常
# ==========================================
if [[ $EUID -ne 0 ]]; then
    echo "Error: Permission denied. Please run this script with sudo."
    echo "Try: sudo $0"
    exit 1
fi

# 配置文件路径
CONF_FILE="/boot/extlinux/extlinux.conf"
BACKUP_FILE="${CONF_FILE}.bak"

# 检查配置文件是否存在
if [ ! -f "$CONF_FILE" ]; then
    echo "Error: $CONF_FILE not found!"
    exit 1
fi

# 显示菜单
clear
echo "=========================================="
echo "   Jetson Camera Configuration Selector"
echo "=========================================="
echo "Please select the camera to enable:"
echo "  0 : S56Cx1_SHF3Lx2"
echo "  1 : S56Cx1_SHW5Gx2"
echo "=========================================="
read -p "Enter number [0-1]: " choice

# 根据选择动态设置变量
case $choice in
    0)
        OVERLAY_FILE="tegra264-camera-sgcam-s56cx1-shf3lx2-overlay.dtbo"
        MENU_LABEL_NAME="Jetson Sensing SG8A_AGTH_G2Y_A1 S56Cx1_SHF3Lx2"
        ;;
    1)
        OVERLAY_FILE="tegra264-camera-sgcam-s56cx1-shw5gx2-overlay.dtbo"
        MENU_LABEL_NAME="Jetson Sensing SG8A_AGTH_G2Y_A1 S56Cx1_SHW5Gx2"
        ;;
    *)
        echo "Invalid selection. Exiting."
        exit 1
        ;;
esac

echo ""
echo "Target Menu Label: $MENU_LABEL_NAME"
echo "Target Overlay File: $OVERLAY_FILE"

# 强制覆盖当前文件（回到初始状态）
cp "$BACKUP_FILE" "$CONF_FILE"
echo "System reset to default state using backup..."

# ==========================================
# 核心逻辑：强制动态读取真实参数
# ==========================================

# 1. 动态提取 INITRD 路径
INITRD_PATH=$(awk '/^LABEL primary/{found=1} found && /^      INITRD /{print $2; exit}' "$CONF_FILE")

# 2. 动态提取 APPEND 整行参数 (去除行首空格和 APPEND 关键字)
APPEND_LINE=$(awk '/^LABEL primary/{found=1} found && /^      APPEND /{sub(/^      APPEND /, ""); print; exit}' "$CONF_FILE")

# 3. 严格校验
if [ -z "$INITRD_PATH" ] || [ -z "$APPEND_LINE" ]; then
    echo "CRITICAL ERROR: Failed to extract boot parameters from $CONF_FILE"
    echo "Please check the format of 'LABEL primary' in the config file."
    exit 1
fi

# 4. 核心修改：将 DEFAULT 引导项更改为 JetsonIO
sed -i 's/^DEFAULT primary/DEFAULT JetsonIO/' "$CONF_FILE"

# 5. 构造并追加新的启动项到文件末尾（核心修改点：使用 sudo tee -a 代替 >>）
cat <<EOF | sudo tee -a "$CONF_FILE" > /dev/null

LABEL JetsonIO
      MENU LABEL Custom Header Config: <$MENU_LABEL_NAME>
      LINUX /boot/Image
      FDT /boot/dtb/kernel_tegra264-p4071-0008+p3834-0008-nv.dtb
      INITRD $INITRD_PATH
      APPEND $APPEND_LINE
      OVERLAYS /boot/$OVERLAY_FILE
EOF

echo ""
echo "Configuration updated successfully."
echo ""
echo "Please reboot to apply changes: sudo reboot"