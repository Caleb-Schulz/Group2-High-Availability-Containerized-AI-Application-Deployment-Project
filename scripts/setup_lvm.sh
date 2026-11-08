#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-/dev/sdb}"
VG_NAME="vg_rag"

echo "=== Verifying LVM Volume Group ==="
if ! sudo vgs "$VG_NAME" > /dev/null 2>&1; then
    echo "Creating PV on $TARGET_DEVICE and VG $VG_NAME..."
    sudo pvcreate "$TARGET_DEVICE"
    sudo vgcreate "$VG_NAME" "$TARGET_DEVICE"
else
    echo "Volume group $VG_NAME already exists. Skipping VG creation."
fi