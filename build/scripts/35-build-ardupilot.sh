#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=./lib.sh
. "$SCRIPT_DIR/lib.sh"

main() {
    load_versions
    ensure_dirs

    local rootfs_dir="$REPO_ROOT/$OUT_ROOT/rootfs/$CANDIDATE_ID"
    local ardupilot_src="$REPO_ROOT/$SRC_ROOT/ardupilot"
    local ardupilot_out="$REPO_ROOT/$OUT_ROOT/ardupilot/$CANDIDATE_ID"

    [ -d "$rootfs_dir" ]    || die "Rootfs not found."
    [ -d "$ardupilot_src" ] || die "ArduPilot source not found. Run 10-fetch-sources.sh first."

    log "Building ArduPilot ($ARDUPILOT_VEHICLE) for board $ARDUPILOT_BOARD"

    run_cmd mkdir -p "$ardupilot_out"

    if [ "${DRY_RUN:-0}" = "1" ]; then
        log "DRY_RUN: would build ArduPilot $ARDUPILOT_VEHICLE for $ARDUPILOT_BOARD"
        log "DRY_RUN: would install binary to rootfs /usr/bin/arducopter"
        return 0
    fi

    # Ensure submodules are initialized
    log "Initializing ArduPilot submodules"
    (cd "$ardupilot_src" && git submodule update --init --recursive)

    # Patch boards.py to support arm64 native build for navio2.
    # The stock navio2 board uses arm-linux-gnueabihf (32-bit).
    # Since we're building on aarch64 for an arm64 rootfs, we add a
    # navio2_64 board that inherits navio2 settings with native toolchain.
    local boards_py="$ardupilot_src/Tools/ardupilotwaf/boards.py"
    if ! grep -q 'class navio2_64' "$boards_py"; then
        log "Patching boards.py to add navio2_64 (arm64 native) board"
        cat >> "$boards_py" <<'PATCH'

class navio2_64(navio2):
    toolchain = 'native'
PATCH
    fi

    # Configure and build
    log "Configuring waf for navio2_64"
    (cd "$ardupilot_src" && ./waf configure --board navio2_64)

    log "Building $ARDUPILOT_VEHICLE"
    (cd "$ardupilot_src" && ./waf "$ARDUPILOT_VEHICLE" -j"$KERNEL_JOBS")

    # Locate the built binary
    local vehicle_bin="arducopter"
    case "$ARDUPILOT_VEHICLE" in
        copter) vehicle_bin="arducopter" ;;
        plane)  vehicle_bin="arduplane"  ;;
        rover)  vehicle_bin="ardurover"  ;;
        sub)    vehicle_bin="ardusub"    ;;
    esac

    local built="$ardupilot_src/build/navio2_64/bin/$vehicle_bin"
    [ -f "$built" ] || die "ArduPilot binary not found at $built"

    # Copy to output and install into rootfs
    cp "$built" "$ardupilot_out/"
    install -m 0755 "$built" "$rootfs_dir/usr/bin/$vehicle_bin"

    log "ArduPilot build complete: $vehicle_bin installed to rootfs"
}

main "$@"
