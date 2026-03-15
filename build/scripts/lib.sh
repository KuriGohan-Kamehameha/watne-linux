#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH='' cd -- "${SCRIPT_DIR}/../.." && pwd)"
VERSIONS_FILE_DEFAULT="${REPO_ROOT}/build/config/versions.env"
VERSIONS_FILE="${VERSIONS_FILE:-$VERSIONS_FILE_DEFAULT}"

log() {
    printf '%s [build] %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$*"
}

die() {
    log "ERROR: $*"
    exit 1
}

load_versions() {
    [ -f "$VERSIONS_FILE" ] || die "Missing versions file: $VERSIONS_FILE"
    # shellcheck disable=SC1090
    . "$VERSIONS_FILE"
    : "${WORK_ROOT:?WORK_ROOT is required}"
    : "${SRC_ROOT:?SRC_ROOT is required}"
    : "${OUT_ROOT:?OUT_ROOT is required}"
    : "${LOG_ROOT:?LOG_ROOT is required}"
}

ensure_dirs() {
    mkdir -p "$REPO_ROOT/$WORK_ROOT" "$REPO_ROOT/$SRC_ROOT" "$REPO_ROOT/$OUT_ROOT" "$REPO_ROOT/$LOG_ROOT"
}

run_cmd() {
    if [ "${DRY_RUN:-0}" = "1" ]; then
        log "DRY_RUN: $*"
        return 0
    fi
    "$@"
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

# Mount virtual filesystems for chroot and execute a command.
# Usage: chroot_cmd /path/to/rootfs command [args...]
chroot_cmd() {
    local rootfs="$1"; shift

    if [ "${DRY_RUN:-0}" = "1" ]; then
        log "DRY_RUN: chroot $rootfs $*"
        return 0
    fi

    mount --bind /proc "$rootfs/proc" 2>/dev/null || true
    mount --bind /sys  "$rootfs/sys"  2>/dev/null || true
    mount --bind /dev  "$rootfs/dev"  2>/dev/null || true
    mount --bind /dev/pts "$rootfs/dev/pts" 2>/dev/null || true
    cp /etc/resolv.conf "$rootfs/etc/resolv.conf" 2>/dev/null || true

    local rc=0
    chroot "$rootfs" "$@" || rc=$?

    umount "$rootfs/dev/pts" 2>/dev/null || true
    umount "$rootfs/dev"     2>/dev/null || true
    umount "$rootfs/sys"     2>/dev/null || true
    umount "$rootfs/proc"    2>/dev/null || true

    return $rc
}

# Bind-mount virtual filesystems for chroot (call once, cleanup with chroot_teardown).
chroot_setup() {
    local rootfs="$1"
    mount --bind /proc "$rootfs/proc" 2>/dev/null || true
    mount --bind /sys  "$rootfs/sys"  2>/dev/null || true
    mount --bind /dev  "$rootfs/dev"  2>/dev/null || true
    mount --bind /dev/pts "$rootfs/dev/pts" 2>/dev/null || true
    cp /etc/resolv.conf "$rootfs/etc/resolv.conf" 2>/dev/null || true
}

chroot_teardown() {
    local rootfs="$1"
    umount "$rootfs/dev/pts" 2>/dev/null || true
    umount "$rootfs/dev"     2>/dev/null || true
    umount "$rootfs/sys"     2>/dev/null || true
    umount "$rootfs/proc"    2>/dev/null || true
}
