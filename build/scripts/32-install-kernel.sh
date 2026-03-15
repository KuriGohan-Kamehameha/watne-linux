#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=./lib.sh
. "$SCRIPT_DIR/lib.sh"

ROOTFS_DIR=""

cleanup_chroot() {
    [ -n "$ROOTFS_DIR" ] && chroot_teardown "$ROOTFS_DIR"
}

main() {
    load_versions
    ensure_dirs

    ROOTFS_DIR="$REPO_ROOT/$OUT_ROOT/rootfs/$CANDIDATE_ID"
    local rootfs_dir="$ROOTFS_DIR"
    local kernel_artifacts="$REPO_ROOT/$OUT_ROOT/kernel/$CANDIDATE_ID/artifacts"
    local kernel_build="$REPO_ROOT/$OUT_ROOT/kernel/$CANDIDATE_ID/build"
    local boot_staging="$REPO_ROOT/$OUT_ROOT/boot-staging/$CANDIDATE_ID"

    [ -d "$rootfs_dir" ]       || die "Rootfs not found. Run 30/31 first."
    [ -d "$kernel_artifacts" ] || die "Kernel artifacts not found. Run 20-build-kernel.sh first."

    # Find the kernel version string from the modules directory
    local kver
    kver="$(ls "$kernel_artifacts/modules/lib/modules/" | head -1)"
    log "Kernel version: $kver"

    # --- Install modules into rootfs ---
    log "Installing kernel modules into rootfs"
    run_cmd mkdir -p "$rootfs_dir/lib/modules"
    run_cmd cp -a "$kernel_artifacts/modules/lib/modules/$kver" "$rootfs_dir/lib/modules/$kver"

    if [ "${DRY_RUN:-0}" != "1" ]; then
        chroot_setup "$rootfs_dir"
        trap cleanup_chroot EXIT
        log "Running depmod for $kver"
        chroot "$rootfs_dir" depmod "$kver"
        chroot_teardown "$rootfs_dir"
        trap - EXIT
    else
        log "DRY_RUN: would run depmod $kver"
    fi

    # --- Stage boot files ---
    log "Staging boot partition files"
    run_cmd mkdir -p "$boot_staging"

    # Kernel image renamed to kernel8.img (RPi4 arm64 convention)
    run_cmd cp "$kernel_artifacts/$KERNEL_IMAGE_NAME" "$boot_staging/kernel8.img"

    # DTBs from kernel build (not firmware — these match our kernel)
    if [ -d "$kernel_build/arch/arm64/boot/dts/broadcom" ]; then
        run_cmd cp "$kernel_build/arch/arm64/boot/dts/broadcom"/bcm2711*.dtb "$boot_staging/"
    fi

    # DT overlays from kernel build
    if [ -d "$kernel_build/arch/arm64/boot/dts/overlays" ]; then
        run_cmd mkdir -p "$boot_staging/overlays"
        run_cmd cp "$kernel_build/arch/arm64/boot/dts/overlays/"*.dtbo "$boot_staging/overlays/"
    fi

    log "Kernel installation complete. Boot staging at $boot_staging"
}

main "$@"
