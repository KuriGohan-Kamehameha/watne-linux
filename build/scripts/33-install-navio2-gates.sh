#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=./lib.sh
. "$SCRIPT_DIR/lib.sh"

main() {
    load_versions
    ensure_dirs

    local rootfs_dir="$REPO_ROOT/$OUT_ROOT/rootfs/$CANDIDATE_ID"
    local gates_dir="$REPO_ROOT/navio2-gates"

    [ -d "$rootfs_dir" ] || die "Rootfs not found."
    [ -d "$gates_dir" ]  || die "navio2-gates directory not found."

    log "Installing navio2-gates into rootfs"

    # Install gate scripts
    run_cmd install -d "$rootfs_dir/usr/local/lib/navio2-gates"
    run_cmd install -m 0755 "$gates_dir/scripts/"*.sh "$rootfs_dir/usr/local/lib/navio2-gates/"

    # Install environment file
    run_cmd install -d "$rootfs_dir/etc/default"
    run_cmd install -m 0644 "$gates_dir/env/navio2-gates.env" "$rootfs_dir/etc/default/navio2-gates"

    # Install systemd units
    run_cmd install -m 0644 "$gates_dir/systemd/navio2-"*.service "$rootfs_dir/etc/systemd/system/"

    # Install ArduPilot override
    run_cmd install -d "$rootfs_dir/etc/systemd/system/ardupilot.service.d"
    run_cmd install -m 0644 "$gates_dir/systemd/ardupilot.service.override.example" \
        "$rootfs_dir/etc/systemd/system/ardupilot.service.d/override.conf"

    # Install the ardupilot.service itself
    local ardupilot_service="$REPO_ROOT/build/overlays/systemd/ardupilot.service"
    if [ -f "$ardupilot_service" ]; then
        run_cmd install -m 0644 "$ardupilot_service" "$rootfs_dir/etc/systemd/system/"
    fi

    if [ "${DRY_RUN:-0}" = "1" ]; then
        log "DRY_RUN: would enable navio2 gate services"
        return 0
    fi

    # Enable gate services
    chroot_setup "$rootfs_dir"
    trap 'chroot_teardown "$rootfs_dir"' EXIT

    chroot "$rootfs_dir" systemctl enable \
        navio2-modules.service \
        navio2-permissions.service \
        navio2-time-sync.service \
        navio2-gps-lock.service \
        navio2-preflight.service

    chroot "$rootfs_dir" systemctl enable ardupilot.service || \
        log "WARNING: ardupilot.service enable failed (may not be installed yet)"

    chroot_teardown "$rootfs_dir"
    trap - EXIT

    log "navio2-gates installation complete"
}

main "$@"
