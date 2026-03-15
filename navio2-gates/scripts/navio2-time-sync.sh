#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="navio2-time-sync"
SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
DEFAULT_ENV_FILE="${SCRIPT_DIR%/scripts}/env/navio2-gates.env"
ENV_FILE="${NAVIO2_GATES_ENV_FILE:-/etc/default/navio2-gates}"

if [ ! -f "$ENV_FILE" ] && [ -f "$DEFAULT_ENV_FILE" ]; then
    ENV_FILE="$DEFAULT_ENV_FILE"
fi

if [ -f "$ENV_FILE" ]; then
    # shellcheck disable=SC1090
    . "$ENV_FILE"
fi

DRY_RUN="${DRY_RUN:-0}"
TIME_SYNC_TIMEOUT_SEC="${TIME_SYNC_TIMEOUT_SEC:-120}"
TIME_SYNC_INTERVAL_SEC="${TIME_SYNC_INTERVAL_SEC:-2}"

log() {
    printf '%s [%s] %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$SCRIPT_NAME" "$*"
}

warn() {
    log "WARN: $*"
}

error() {
    log "ERROR: $*"
}

is_time_synchronized() {
    local ntp_value
    local clock_value

    ntp_value="$(timedatectl show -p NTPSynchronized --value 2>/dev/null || true)"
    clock_value="$(timedatectl show -p SystemClockSynchronized --value 2>/dev/null || true)"

    if [ "$ntp_value" = "yes" ] || [ "$clock_value" = "yes" ]; then
        return 0
    fi

    return 1
}

main() {
    local elapsed=0

    log "Starting time sync gate (DRY_RUN=$DRY_RUN timeout=${TIME_SYNC_TIMEOUT_SEC}s interval=${TIME_SYNC_INTERVAL_SEC}s)"

    if ! command -v timedatectl >/dev/null 2>&1; then
        if [ "$DRY_RUN" = "1" ]; then
            warn "timedatectl not available in dry-run; continuing"
            return 0
        fi
        error "timedatectl command is required but not available"
        return 1
    fi

    while [ "$elapsed" -lt "$TIME_SYNC_TIMEOUT_SEC" ]; do
        if is_time_synchronized; then
            log "System time is synchronized"
            return 0
        fi

        log "Waiting for time sync (${elapsed}s/${TIME_SYNC_TIMEOUT_SEC}s)"
        sleep "$TIME_SYNC_INTERVAL_SEC"
        elapsed=$((elapsed + TIME_SYNC_INTERVAL_SEC))
    done

    if [ "$DRY_RUN" = "1" ]; then
        warn "Timeout waiting for time sync in dry-run; continuing"
        return 0
    fi

    error "Timeout waiting for time synchronization"
    return 1
}

main "$@"
