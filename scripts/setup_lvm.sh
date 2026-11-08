#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-/dev/sdb}"
VG_NAME="vg_rag"
LV_DB_NAME="lv_db"
LV_MODELS_NAME="lv_models"

MOUNT_DB="/data/db"
MOUNT_MODELS="/models"

echo "=== Verifying LVM Volume Group ==="
if ! sudo vgs "$VG_NAME" > /dev/null 2>&1; then
    echo "Creating PV on $TARGET_DEVICE and VG $VG_NAME..."
    sudo pvcreate "$TARGET_DEVICE"
    sudo vgcreate "$VG_NAME" "$TARGET_DEVICE"
else
    echo "Volume group $VG_NAME already exists. Skipping VG creation."
fi

echo "=== Verifying Logical Volumes ==="
if ! sudo lvs "$VG_NAME/$LV_DB_NAME" > /dev/null 2>&1; then
    echo "Creating $LV_DB_NAME (15G)..."
    sudo lvcreate -L 15G -n "$LV_DB_NAME" "$VG_NAME"
    sudo mkfs.ext4 "/dev/$VG_NAME/$LV_DB_NAME"
else
    echo "Logical volume $LV_DB_NAME already exists."
fi

if ! sudo lvs "$VG_NAME/$LV_MODELS_NAME" > /dev/null 2>&1; then
    echo "Creating $LV_MODELS_NAME (25G)..."
    sudo lvcreate -L 25G -n "$LV_MODELS_NAME" "$VG_NAME"
    sudo mkfs.ext4 "/dev/$VG_NAME/$LV_MODELS_NAME"
else
    echo "Logical volume $LV_MODELS_NAME already exists."
fi

echo "=== Configuring Persistent Mounts in /etc/fstab ==="
sudo mkdir -p "$MOUNT_DB" "$MOUNT_MODELS"

if ! grep -qs "$MOUNT_DB" /etc/fstab; then
    echo "/dev/$VG_NAME/$LV_DB_NAME $MOUNT_DB ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
fi

if ! grep -qs "$MOUNT_MODELS" /etc/fstab; then
    echo "/dev/$VG_NAME/$LV_MODELS_NAME $MOUNT_MODELS ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
fi

sudo mount -a