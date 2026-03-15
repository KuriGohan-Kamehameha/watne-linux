#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=./lib.sh
. "$SCRIPT_DIR/lib.sh"

PASS=0
FAIL=0

check() {
    local desc="$1"; shift
    if "$@" >/dev/null 2>&1; then
        log "PASS: $desc"
        PASS=$((PASS + 1))
    else
        log "FAIL: $desc"
        FAIL=$((FAIL + 1))
    fi
}

check_file() {
    local desc="$1"
    local path="$2"
    check "$desc" test -f "$path"
}

check_dir() {
    local desc="$1"
    local path="$2"
    check "$desc" test -d "$path"
}

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

    local images_dir="$REPO_ROOT/$OUT_ROOT/images"
    local image_xz="$images_dir/$CANDIDATE_ID.img.xz"
    local image_file="$images_dir/$CANDIDATE_ID-verify.img"

    if [ "${DRY_RUN:-0}" = "1" ]; then
        log "DRY_RUN: would verify image contents"
        return 0
    fi

    [ -f "$image_xz" ] || die "Compressed image not found: $image_xz"

    log "Verifying image: $image_xz"

    # Decompress to temp file for verification
    log "Decompressing image for verification"
    xz -dk "$image_xz" -c > "$image_file"
    trap 'rm -f "$image_file"' EXIT

    # Get partition offsets
    local boot_start boot_size root_start root_size
    boot_start=$(sfdisk -d "$image_file" | grep "${image_file}1" | sed 's/.*start= *//' | sed 's/,.*//' | tr -d ' ')
    boot_size=$(sfdisk -d "$image_file" | grep "${image_file}1" | sed 's/.*size= *//' | sed 's/,.*//' | tr -d ' ')
    root_start=$(sfdisk -d "$image_file" | grep "${image_file}2" | sed 's/.*start= *//' | sed 's/,.*//' | tr -d ' ')
    root_size=$(sfdisk -d "$image_file" | grep "${image_file}2" | sed 's/.*size= *//' | sed 's/,.*//' | tr -d ' ')

    local boot_offset=$(( boot_start * 512 ))
    local boot_bytes=$(( boot_size * 512 ))
    local root_offset=$(( root_start * 512 ))
    local root_bytes=$(( root_size * 512 ))

    local loop_boot loop_root
    loop_boot="$(losetup --find --show --offset "$boot_offset" --sizelimit "$boot_bytes" --read-only "$image_file")"
    loop_root="$(losetup --find --show --offset "$root_offset" --sizelimit "$root_bytes" --read-only "$image_file")"

    local mount_boot mount_root
    mount_boot="$(mktemp -d)"
    mount_root="$(mktemp -d)"
    trap 'cleanup "$mount_boot" "$mount_root" "$loop_boot" "$loop_root"; rm -f "$image_file"' EXIT

    mount -o ro "$loop_boot" "$mount_boot"
    mount -o ro "$loop_root" "$mount_root"

    log "=== Boot Partition ==="
    check_file "kernel8.img present"       "$mount_boot/kernel8.img"
    check_file "config.txt present"        "$mount_boot/config.txt"
    check_file "cmdline.txt present"       "$mount_boot/cmdline.txt"
    check_file "start4.elf present"        "$mount_boot/start4.elf"
    check_dir  "overlays/ present"         "$mount_boot/overlays"

    log "=== Rootfs: Branding ==="
    check_file "os-release present"        "$mount_root/etc/os-release"
    check "os-release has watne-linux"     grep -q 'watne-linux' "$mount_root/etc/os-release"
    check_file "hostname present"          "$mount_root/etc/hostname"
    check "hostname is watne-linux"        grep -q 'watne-linux' "$mount_root/etc/hostname"

    log "=== Rootfs: ArduPilot ==="
    check_file "arducopter binary"         "$mount_root/usr/bin/arducopter"
    check_file "ardupilot.service"         "$mount_root/etc/systemd/system/ardupilot.service"

    log "=== Rootfs: Navio2 Gates ==="
    check_dir  "gate scripts dir"          "$mount_root/usr/local/lib/navio2-gates"
    check_file "navio2-gates env"          "$mount_root/etc/default/navio2-gates"
    check_file "modules gate service"      "$mount_root/etc/systemd/system/navio2-modules.service"
    check_file "preflight gate service"    "$mount_root/etc/systemd/system/navio2-preflight.service"
    check_file "ardupilot override"        "$mount_root/etc/systemd/system/ardupilot.service.d/override.conf"

    log "=== Rootfs: ROS 2 ==="
    check_file "ROS 2 setup.bash"          "$mount_root/opt/ros/$ROS2_DISTRO/setup.bash"

    log "=== Rootfs: RealSense ==="
    check "librealsense2 installed" \
        find "$mount_root/usr/local/lib" -name 'librealsense2*' -print -quit

    log "=== Rootfs: watnetool ==="
    check_file "watnetool binary" "$mount_root/usr/local/bin/watnetool"

    log "=== Rootfs: Kernel ==="
    check_dir  "kernel modules dir"        "$mount_root/lib/modules"
    check_file "fstab present"             "$mount_root/etc/fstab"
    check "fstab has mmcblk0p2"           grep -q 'mmcblk0p2' "$mount_root/etc/fstab"

    # Cleanup
    umount "$mount_boot"
    umount "$mount_root"
    losetup -d "$loop_boot"
    losetup -d "$loop_root"
    rm -f "$image_file"
    rmdir "$mount_boot" "$mount_root"
    trap - EXIT

    log "=== Summary ==="
    log "Passed: $PASS  Failed: $FAIL"

    if [ "$FAIL" -gt 0 ]; then
        die "Image verification failed ($FAIL checks)"
    fi

    log "Image verification PASSED"

    # Print final image info
    local img_size
    img_size="$(du -h "$image_xz" | awk '{print $1}')"
    log "Final image: $image_xz ($img_size)"
    log "SHA256: $(cat "$images_dir/$CANDIDATE_ID.img.xz.sha256")"
}

main "$@"
