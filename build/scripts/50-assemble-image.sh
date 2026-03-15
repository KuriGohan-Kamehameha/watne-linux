#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=./lib.sh
. "$SCRIPT_DIR/lib.sh"

cleanup() {
    local mount_boot="${1:-}"
    local mount_root="${2:-}"
    local loop_boot="${3:-}"
    local loop_root="${4:-}"

    [ -n "$mount_boot" ] && mountpoint -q "$mount_boot" && umount "$mount_boot" 2>/dev/null || true
    [ -n "$mount_root" ] && mountpoint -q "$mount_root" && umount "$mount_root" 2>/dev/null || true
    [ -n "$loop_boot" ] && losetup -d "$loop_boot" 2>/dev/null || true
    [ -n "$loop_root" ] && losetup -d "$loop_root" 2>/dev/null || true
    [ -n "$mount_boot" ] && rmdir "$mount_boot" 2>/dev/null || true
    [ -n "$mount_root" ] && rmdir "$mount_root" 2>/dev/null || true
}

main() {
    load_versions
    ensure_dirs

    local rootfs_dir="$REPO_ROOT/$OUT_ROOT/rootfs/$CANDIDATE_ID"
    local boot_staging="$REPO_ROOT/$OUT_ROOT/boot-staging/$CANDIDATE_ID"
    local firmware_boot="$REPO_ROOT/$SRC_ROOT/firmware/boot"
    local overlays_dir="$REPO_ROOT/build/overlays"
    local images_dir="$REPO_ROOT/$OUT_ROOT/images"
    local image_file="$images_dir/$CANDIDATE_ID.img"

    [ -d "$rootfs_dir" ]    || die "Rootfs not found."
    [ -d "$boot_staging" ]  || die "Boot staging not found. Run 32-install-kernel.sh first."

    log "Assembling bootable image: $image_file"

    run_cmd mkdir -p "$images_dir"

    if [ "${DRY_RUN:-0}" = "1" ]; then
        log "DRY_RUN: would create partitioned image, populate boot and rootfs"
        return 0
    fi

    require_cmd sfdisk
    require_cmd mkfs.vfat
    require_cmd mkfs.ext4
    require_cmd losetup
    require_cmd rsync

    # --- Calculate image size ---
    local boot_mb="${BOOT_PARTITION_SIZE_MB:-256}"
    local rootfs_bytes
    rootfs_bytes="$(du -sb "$rootfs_dir" | awk '{print $1}')"
    local rootfs_mb=$(( (rootfs_bytes / 1024 / 1024) + 1 ))
    # Add 20% headroom
    local rootfs_total_mb=$(( rootfs_mb * 120 / 100 ))
    # Total: boot + rootfs + 4MB alignment buffer
    local total_mb=$(( boot_mb + rootfs_total_mb + 4 ))

    log "Image size: ${total_mb}MB (boot=${boot_mb}MB, rootfs=${rootfs_total_mb}MB)"

    # --- Create sparse image ---
    truncate -s "${total_mb}M" "$image_file"

    # --- Partition (MBR) ---
    log "Creating MBR partition table"
    sfdisk "$image_file" <<EOF
label: dos
,${boot_mb}M,0x0C,*
,,0x83
EOF

    # --- Get partition offsets from sfdisk ---
    local boot_start boot_size root_start root_size
    boot_start=$(sfdisk -d "$image_file" | grep "${image_file}1" | sed 's/.*start= *//' | sed 's/,.*//' | tr -d ' ')
    boot_size=$(sfdisk -d "$image_file" | grep "${image_file}1" | sed 's/.*size= *//' | sed 's/,.*//' | tr -d ' ')
    root_start=$(sfdisk -d "$image_file" | grep "${image_file}2" | sed 's/.*start= *//' | sed 's/,.*//' | tr -d ' ')
    root_size=$(sfdisk -d "$image_file" | grep "${image_file}2" | sed 's/.*size= *//' | sed 's/,.*//' | tr -d ' ')

    local boot_offset=$(( boot_start * 512 ))
    local boot_bytes=$(( boot_size * 512 ))
    local root_offset=$(( root_start * 512 ))
    local root_bytes=$(( root_size * 512 ))

    # --- Set up loop devices with offset/sizelimit ---
    local loop_boot loop_root
    loop_boot="$(losetup --find --show --offset "$boot_offset" --sizelimit "$boot_bytes" "$image_file")"
    loop_root="$(losetup --find --show --offset "$root_offset" --sizelimit "$root_bytes" "$image_file")"

    local mount_boot mount_root
    mount_boot="$(mktemp -d)"
    mount_root="$(mktemp -d)"
    trap 'cleanup "$mount_boot" "$mount_root" "$loop_boot" "$loop_root"' EXIT

    # --- Format ---
    log "Formatting partitions"
    mkfs.vfat -F 32 -n BOOT "$loop_boot"
    mkfs.ext4 -L rootfs -O ^metadata_csum -q "$loop_root"

    # --- Mount ---
    mount "$loop_boot" "$mount_boot"
    mount "$loop_root" "$mount_root"

    # --- Populate boot partition ---
    log "Populating boot partition"

    # Firmware files from RPi firmware repo
    for f in bootcode.bin start4.elf start4x.elf fixup4.dat fixup4x.dat LICENCE.broadcom; do
        [ -f "$firmware_boot/$f" ] && cp "$firmware_boot/$f" "$mount_boot/"
    done

    # Kernel image and DTBs from our build
    cp "$boot_staging/kernel8.img" "$mount_boot/"
    cp "$boot_staging"/bcm2711*.dtb "$mount_boot/" 2>/dev/null || true

    # DT overlays — prefer kernel build overlays, fall back to firmware
    if [ -d "$boot_staging/overlays" ]; then
        cp -r "$boot_staging/overlays" "$mount_boot/"
    elif [ -d "$firmware_boot/overlays" ]; then
        cp -r "$firmware_boot/overlays" "$mount_boot/"
    fi

    # Boot config
    cp "$overlays_dir/boot/config.txt" "$mount_boot/"
    cp "$overlays_dir/boot/cmdline.txt" "$mount_boot/"

    # --- Populate rootfs ---
    log "Populating rootfs partition (this may take a while)"
    rsync -aHAXx "$rootfs_dir/" "$mount_root/"

    # Create boot/firmware mountpoint
    mkdir -p "$mount_root/boot/firmware"

    # --- Sync and unmount ---
    sync
    umount "$mount_boot"
    umount "$mount_root"

    # --- Shrink rootfs partition ---
    log "Shrinking rootfs partition to minimum size"
    e2fsck -f -y "$loop_root" || true
    resize2fs -M "$loop_root"

    # Get the new filesystem size in 512-byte sectors
    local block_count block_size
    block_count="$(dumpe2fs -h "$loop_root" 2>/dev/null | grep 'Block count:' | awk '{print $3}')"
    block_size="$(dumpe2fs -h "$loop_root" 2>/dev/null | grep 'Block size:' | awk '{print $3}')"
    local fs_bytes=$(( block_count * block_size ))
    local fs_sectors=$(( fs_bytes / 512 ))

    local new_end_sector=$(( root_start + fs_sectors + 2048 ))  # 1MB safety buffer

    losetup -d "$loop_boot"
    losetup -d "$loop_root"
    rmdir "$mount_boot" "$mount_root"
    trap - EXIT

    # Truncate image to new size
    local new_size_bytes=$(( new_end_sector * 512 ))
    truncate -s "$new_size_bytes" "$image_file"

    # --- Compress ---
    log "Compressing image with xz"
    xz -9 --threads=0 -f "$image_file"

    local final_file="$image_file.xz"
    local final_size
    final_size="$(du -h "$final_file" | awk '{print $1}')"

    log "Image assembly complete: $final_file ($final_size)"

    # Checksum
    sha256sum "$final_file" | tee "$images_dir/$CANDIDATE_ID.img.xz.sha256"
}

main "$@"
