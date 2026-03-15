#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=./lib.sh
. "$SCRIPT_DIR/lib.sh"

ALLOW_NON_LINUX="${ALLOW_NON_LINUX:-0}"
ALLOW_CASE_INSENSITIVE="${ALLOW_CASE_INSENSITIVE:-0}"
ALLOW_SCAFFOLD_ONLY=0

if [ "${DRY_RUN:-0}" = "1" ] || [ "$ALLOW_NON_LINUX" = "1" ]; then
    ALLOW_SCAFFOLD_ONLY=1
fi

main() {
    load_versions
    ensure_dirs

    log "Running prerequisite checks"

    if [ "$(uname -s)" != "Linux" ] && [ "$ALLOW_NON_LINUX" != "1" ]; then
        die "Host is not Linux. Use a Linux VM/runner or set ALLOW_NON_LINUX=1 for scaffolding only."
    fi

    require_cmd git
    require_cmd bash
    require_cmd "${MAKE_BIN:-make}"

    local make_ver
    make_ver="$(${MAKE_BIN:-make} --version | awk 'NR==1 {print $3}')"
    case "$make_ver" in
        ''|*[!0-9.]*)
            die "Unable to determine GNU Make version for ${MAKE_BIN:-make}"
            ;;
    esac
    if [ "${make_ver%%.*}" -lt 4 ]; then
        if [ "$ALLOW_SCAFFOLD_ONLY" = "1" ]; then
            log "WARN: GNU Make >= 4 required for real builds. Found $make_ver via ${MAKE_BIN:-make}."
        else
            die "GNU Make >= 4 is required. Found $make_ver via ${MAKE_BIN:-make}."
        fi
    fi

    local fs_test_dir
    fs_test_dir="$REPO_ROOT/$WORK_ROOT/.fs_case_test"
    rm -rf "$fs_test_dir"
    mkdir -p "$fs_test_dir"
    touch "$fs_test_dir/lower"
    touch "$fs_test_dir/LOWER" 2>/dev/null || true
    local file_count
    file_count="$(find "$fs_test_dir" -maxdepth 1 -type f | wc -l | tr -d '[:space:]')"
    if [ "$file_count" -ge 2 ]; then
        log "Filesystem appears case-sensitive"
    else
        rm -rf "$fs_test_dir"
        if [ "$ALLOW_CASE_INSENSITIVE" = "1" ] || [ "$ALLOW_NON_LINUX" = "1" ]; then
            log "WARN: Filesystem appears case-insensitive. Kernel sources may collide."
        else
            die "Case-sensitive filesystem is required for kernel source checkout."
        fi
    fi
    rm -rf "$fs_test_dir"

    if command -v "${CROSS_COMPILE}gcc" >/dev/null 2>&1; then
        log "Cross compiler found: ${CROSS_COMPILE}gcc"
    else
        if [ "${DRY_RUN:-0}" = "1" ] || [ "$ALLOW_NON_LINUX" = "1" ]; then
            log "WARN: Cross compiler missing: ${CROSS_COMPILE}gcc"
        else
            die "Cross compiler missing: ${CROSS_COMPILE}gcc"
        fi
    fi

    log "Prerequisite checks passed"
}

main "$@"
