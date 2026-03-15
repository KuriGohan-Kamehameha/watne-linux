#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=./lib.sh
. "$SCRIPT_DIR/lib.sh"

main() {
    load_versions
    ensure_dirs

    local rootfs_dir="$REPO_ROOT/$OUT_ROOT/rootfs/$CANDIDATE_ID"
    local realsense_src="$REPO_ROOT/$SRC_ROOT/librealsense"

    [ -d "$rootfs_dir" ] || die "Rootfs not found."

    log "Building Intel RealSense SDK ($REALSENSE_TAG)"

    if [ "${DRY_RUN:-0}" = "1" ]; then
        log "DRY_RUN: would clone librealsense $REALSENSE_TAG and build from source"
        return 0
    fi

    # Clone librealsense if not present
    if [ ! -d "$realsense_src" ]; then
        log "Cloning librealsense $REALSENSE_TAG"
        git clone --depth 1 --branch "$REALSENSE_TAG" "$REALSENSE_REPO" "$realsense_src"
    fi

    # Build from source on the host (not in chroot — faster, same arch)
    local build_dir="$realsense_src/build"
    mkdir -p "$build_dir"

    log "Configuring librealsense cmake build"
    cmake -S "$realsense_src" -B "$build_dir" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_GRAPHICAL_EXAMPLES=OFF \
        -DBUILD_WITH_OPENMP=ON \
        -DBUILD_PYTHON_BINDINGS=OFF \
        -DCMAKE_INSTALL_PREFIX=/usr/local

    log "Building librealsense"
    cmake --build "$build_dir" -j"$KERNEL_JOBS"

    log "Installing librealsense into rootfs"
    DESTDIR="$rootfs_dir" cmake --install "$build_dir"

    # Install udev rules
    if [ -d "$realsense_src/config" ]; then
        install -d "$rootfs_dir/etc/udev/rules.d"
        install -m 0644 "$realsense_src/config/99-realsense-libusb.rules" \
            "$rootfs_dir/etc/udev/rules.d/" 2>/dev/null || \
            log "WARNING: RealSense udev rules not found, skipping"
    fi

    # Run ldconfig
    chroot_cmd "$rootfs_dir" ldconfig

    log "Intel RealSense SDK build and installation complete"
}

main "$@"
