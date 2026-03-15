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
    local overlays_dir="$REPO_ROOT/build/overlays"
    local core_manifest="$REPO_ROOT/build/manifests/packages-core.txt"
    local extra_manifest="$REPO_ROOT/build/manifests/packages-rootfs-extra.txt"
    local optional_manifest="$REPO_ROOT/build/manifests/packages-optional.txt"

    [ -d "$rootfs_dir" ] || die "Rootfs not found. Run 30-build-rootfs.sh first."

    log "Configuring rootfs at $rootfs_dir"

    # --- Branding ---
    log "Installing branding files"
    run_cmd sed "s/@@CANDIDATE_ID@@/$CANDIDATE_ID/g" \
        "$overlays_dir/etc/os-release" > "$rootfs_dir/etc/os-release"
    run_cmd cp "$overlays_dir/etc/hostname" "$rootfs_dir/etc/hostname"
    run_cmd cp "$overlays_dir/etc/issue"    "$rootfs_dir/etc/issue"
    run_cmd cp "$overlays_dir/etc/motd"     "$rootfs_dir/etc/motd"

    # --- Networking ---
    log "Configuring systemd-networkd"
    run_cmd mkdir -p "$rootfs_dir/etc/systemd/network"
    run_cmd cp "$overlays_dir/network/10-end0.network" "$rootfs_dir/etc/systemd/network/"

    # --- fstab ---
    log "Writing /etc/fstab"
    cat > "$rootfs_dir/etc/fstab" <<'FSTAB'
/dev/mmcblk0p2  /               ext4    defaults,noatime    0 1
/dev/mmcblk0p1  /boot/firmware  vfat    defaults            0 2
FSTAB
    run_cmd mkdir -p "$rootfs_dir/boot/firmware"

    if [ "${DRY_RUN:-0}" = "1" ]; then
        log "DRY_RUN: would chroot to install packages, create user, configure locale"
        return 0
    fi

    # --- Chroot setup ---
    chroot_setup "$rootfs_dir"
    trap cleanup_chroot EXIT

    # --- APT sources ---
    log "Adding non-free-firmware component to apt sources"
    cat > "$rootfs_dir/etc/apt/sources.list" <<EOF
deb http://deb.debian.org/debian $DEBIAN_RELEASE main contrib non-free-firmware
deb http://deb.debian.org/debian-security $DEBIAN_RELEASE-security main contrib non-free-firmware
deb http://deb.debian.org/debian $DEBIAN_RELEASE-updates main contrib non-free-firmware
EOF

    # --- Package installation ---
    log "Updating package lists"
    chroot "$rootfs_dir" apt-get update -qq

    # Install firmware packages (need non-free-firmware component)
    log "Installing firmware packages"
    chroot "$rootfs_dir" env DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --no-install-recommends \
        firmware-brcm80211 || \
        log "WARNING: some firmware packages failed to install"

    log "Installing core packages"
    local pkgs=()
    while IFS= read -r line; do
        line="${line%%#*}"
        line="${line// /}"
        [ -n "$line" ] && pkgs+=("$line")
    done < "$core_manifest"
    chroot "$rootfs_dir" env DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --no-install-recommends "${pkgs[@]}"

    log "Installing extra build packages"
    pkgs=()
    while IFS= read -r line; do
        line="${line%%#*}"
        line="${line// /}"
        [ -n "$line" ] && pkgs+=("$line")
    done < "$extra_manifest"
    chroot "$rootfs_dir" env DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --no-install-recommends "${pkgs[@]}"

    if [ -f "$optional_manifest" ]; then
        log "Installing optional packages"
        pkgs=()
        while IFS= read -r line; do
            line="${line%%#*}"
            line="${line// /}"
            [ -n "$line" ] && pkgs+=("$line")
        done < "$optional_manifest"
        chroot "$rootfs_dir" env DEBIAN_FRONTEND=noninteractive \
            apt-get install -y --no-install-recommends "${pkgs[@]}" || \
            log "WARNING: some optional packages failed to install"
    fi

    # --- Locale ---
    log "Configuring locale"
    chroot "$rootfs_dir" sed -i 's/^# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
    chroot "$rootfs_dir" locale-gen

    # --- Timezone ---
    chroot "$rootfs_dir" ln -sf /usr/share/zoneinfo/UTC /etc/localtime

    # --- User ---
    log "Creating watne user"
    chroot "$rootfs_dir" useradd -m -s /bin/bash -G sudo,dialout watne 2>/dev/null || \
        log "WARNING: user watne already exists or group missing, continuing"
    # Set password using usermod to avoid PAM issues in chroot
    chroot "$rootfs_dir" bash -c 'echo "watne:$(openssl passwd -6 watne)" | chpasswd -e' || \
        log "WARNING: password set failed, will need to be set on first boot"

    # --- Enable services ---
    log "Enabling systemd-networkd and systemd-resolved"
    chroot "$rootfs_dir" systemctl enable systemd-networkd
    chroot "$rootfs_dir" systemctl enable systemd-resolved 2>/dev/null || \
        log "WARNING: systemd-resolved not available, skipping"
    chroot "$rootfs_dir" systemctl enable ssh

    # --- Cleanup ---
    chroot "$rootfs_dir" apt-get clean
    rm -rf "$rootfs_dir/var/lib/apt/lists/"*

    chroot_teardown "$rootfs_dir"
    trap - EXIT

    log "Rootfs configuration complete"
}

main "$@"
