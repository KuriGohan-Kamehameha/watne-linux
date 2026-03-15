#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "${SCRIPT_DIR}/../.." && pwd)"
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
