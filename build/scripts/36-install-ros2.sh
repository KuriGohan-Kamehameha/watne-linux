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
    local ros_manifest="$REPO_ROOT/build/manifests/packages-ros2.txt"
    local raw_lines=()
    local wanted_pkgs=()
    local install_pkgs=()
    local missing_pkgs=()

    [ -d "$rootfs_dir" ] || die "Rootfs not found."
    [ -f "$ros_manifest" ] || die "Missing ROS package manifest: $ros_manifest"

    log "Installing ROS 2 $ROS2_DISTRO"

    if [ "${DRY_RUN:-0}" = "1" ]; then
        log "DRY_RUN: would add ROS 2 repository and install manifest packages from $ros_manifest"
        return 0
    fi

    chroot_setup "$rootfs_dir"
    trap cleanup_chroot EXIT

    # Install prerequisites (gnupg for GPG key import; curl already installed)
    chroot "$rootfs_dir" apt-get update -qq
    chroot "$rootfs_dir" env DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --no-install-recommends gnupg

    # Add ROS 2 GPG key
    log "Adding ROS 2 repository key"
    chroot "$rootfs_dir" bash -c \
        'curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | gpg --batch --yes --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg'

    # Add repository. ROS 2 Jazzy official debs target Ubuntu Noble.
    # On Debian Trixie arm64 we use the Ubuntu Noble packages which
    # are binary-compatible (same glibc era, same arm64 ABI).
    log "Adding ROS 2 apt source"
    cat > "$rootfs_dir/etc/apt/sources.list.d/ros2.list" <<'EOF'
deb [arch=arm64 signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu noble main
EOF

    chroot "$rootfs_dir" apt-get update -qq

    # Build desired package list from manifest, supporting ${ROS2_DISTRO} placeholders.
    mapfile -t raw_lines < "$ros_manifest"
    for line in "${raw_lines[@]}"; do
        line="${line%%#*}"
        line="${line// /}"
        line="${line//$'\t'/}"
        [ -n "$line" ] || continue
        line="${line//\$\{ROS2_DISTRO\}/$ROS2_DISTRO}"
        wanted_pkgs+=("$line")
    done

    [ "${#wanted_pkgs[@]}" -gt 0 ] || die "ROS manifest is empty after parsing comments: $ros_manifest"

    # Probe package visibility so we only install what exists for this rootfs/arch combo.
    for pkg in "${wanted_pkgs[@]}"; do
        if chroot "$rootfs_dir" apt-cache show "$pkg" >/dev/null 2>&1; then
            install_pkgs+=("$pkg")
        else
            missing_pkgs+=("$pkg")
        fi
    done

    if [ "${#missing_pkgs[@]}" -gt 0 ]; then
        log "ROS packages not available for this image target: ${missing_pkgs[*]}"
    fi

    if [ "${#install_pkgs[@]}" -eq 0 ]; then
        log "WARNING: no compatible ROS packages found from manifest."
        log "Continuing without ROS 2 — install manually on target if needed."
        chroot_teardown "$rootfs_dir"
        trap - EXIT
        return 0
    fi

    log "Installing compatible ROS packages: ${install_pkgs[*]}"
    chroot "$rootfs_dir" env DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --no-install-recommends \
        "${install_pkgs[@]}" || {
        log "WARNING: ROS package install failed for target set: ${install_pkgs[*]}"
        log "Continuing without ROS 2 — install manually on target if needed."
        chroot_teardown "$rootfs_dir"
        trap - EXIT
        return 0
    }

    # Source ROS 2 on login
    cat > "$rootfs_dir/etc/profile.d/ros2.sh" <<EOF
# ROS 2 $ROS2_DISTRO environment
if [ -f /opt/ros/$ROS2_DISTRO/setup.bash ]; then
    . /opt/ros/$ROS2_DISTRO/setup.bash
fi
EOF

    chroot "$rootfs_dir" apt-get clean
    rm -rf "$rootfs_dir/var/lib/apt/lists/"*

    chroot_teardown "$rootfs_dir"
    trap - EXIT

    log "ROS 2 $ROS2_DISTRO installation complete"
}

main "$@"
