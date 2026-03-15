#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=./lib.sh
. "$SCRIPT_DIR/lib.sh"

main() {
    load_versions
    ensure_dirs

    local rootfs_dir="$REPO_ROOT/$OUT_ROOT/rootfs/$CANDIDATE_ID"
    local core_manifest="$REPO_ROOT/build/manifests/packages-core.txt"
    local optional_manifest="$REPO_ROOT/build/manifests/packages-optional.txt"

    log "Preparing rootfs directory: $rootfs_dir"
    run_cmd mkdir -p "$rootfs_dir"

    if [ "$(uname -s)" != "Linux" ] && [ "${DRY_RUN:-0}" != "1" ]; then
        die "Rootfs build requires Linux host. Use DRY_RUN=1 on non-Linux for planning only."
    fi

    if [ "${DRY_RUN:-0}" = "1" ]; then
        log "DRY_RUN: would run debootstrap for $DEBIAN_RELEASE/$TARGET_ARCH"
        log "DRY_RUN: would install core packages from $core_manifest"
        log "DRY_RUN: optional packages listed in $optional_manifest"
        return 0
    fi

    require_cmd debootstrap
    require_cmd chroot

    # Minimal first pass; customize mirror and package install strategy later.
    run_cmd sudo debootstrap --arch="$TARGET_ARCH" "$DEBIAN_RELEASE" "$rootfs_dir" http://deb.debian.org/debian

    log "Rootfs base created. Package install customization is next."
}

main "$@"
