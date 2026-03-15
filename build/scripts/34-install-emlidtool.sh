#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=./lib.sh
. "$SCRIPT_DIR/lib.sh"

main() {
    load_versions
    ensure_dirs

    local rootfs_dir="$REPO_ROOT/$OUT_ROOT/rootfs/$CANDIDATE_ID"
    local watnetool_src="$REPO_ROOT/$SRC_ROOT/watnetool"

    [ -d "$rootfs_dir" ]    || die "Rootfs not found."
    [ -d "$watnetool_src" ] || die "watnetool source not found at $watnetool_src"

    log "Installing watnetool (watne-linux fork of emlidtool)"

    if [ "${DRY_RUN:-0}" = "1" ]; then
        log "DRY_RUN: would install watnetool from local source"
        return 0
    fi

    # Copy watnetool source into rootfs for pip install
    local chroot_src="/tmp/watnetool"
    run_cmd cp -a "$watnetool_src" "$rootfs_dir/$chroot_src"

    chroot_setup "$rootfs_dir"
    trap 'chroot_teardown "$rootfs_dir"; rm -rf "$rootfs_dir/$chroot_src"' EXIT

    log "Installing watnetool via pip from local source"
    chroot "$rootfs_dir" pip3 install --break-system-packages "$chroot_src" || {
        log "WARNING: watnetool pip install failed."
        log "Continuing — install manually on target if needed."
        chroot_teardown "$rootfs_dir"
        rm -rf "$rootfs_dir/$chroot_src"
        trap - EXIT
        return 0
    }

    # Verify
    chroot "$rootfs_dir" watnetool --version || \
        log "WARNING: watnetool --version check failed (may need hardware)"

    # Cleanup source copy from rootfs
    rm -rf "$rootfs_dir/$chroot_src"

    chroot_teardown "$rootfs_dir"
    trap - EXIT

    log "watnetool installation complete"
}

main "$@"
