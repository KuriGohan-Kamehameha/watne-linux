#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=./lib.sh
. "$SCRIPT_DIR/lib.sh"

STOP_ON_FAIL="${STOP_ON_FAIL:-1}"

run_step() {
    local step="$1"
    local path="$SCRIPT_DIR/$step"

    [ -x "$path" ] || die "Missing executable step: $path"
    log "Running step: $step"
    if "$path"; then
        log "Step passed: $step"
    else
        log "Step failed: $step"
        if [ "$STOP_ON_FAIL" = "1" ]; then
            return 1
        fi
    fi
}

main() {
    load_versions
    ensure_dirs

    run_step "00-prereq-check.sh"
    run_step "10-fetch-sources.sh"
    run_step "20-build-kernel.sh"
    run_step "30-build-rootfs.sh"
    run_step "31-configure-rootfs.sh"
    run_step "32-install-kernel.sh"
    run_step "33-install-navio2-gates.sh"
    run_step "34-install-emlidtool.sh"
    run_step "35-build-ardupilot.sh"
    run_step "36-install-ros2.sh"
    run_step "37-build-realsense.sh"
    run_step "50-assemble-image.sh"
    run_step "60-verify-image.sh"

    log "Build orchestrator completed"
}

main "$@"
