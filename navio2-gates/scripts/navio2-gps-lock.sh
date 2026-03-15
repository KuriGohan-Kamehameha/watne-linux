#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="navio2-gps-lock"
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
GPS_STATUS_PATH="${GPS_STATUS_PATH:-/run/navio2/gps_status}"
GPS_LOCK_VALUE="${GPS_LOCK_VALUE:-LOCKED}"
GPS_TIMEOUT_SEC="${GPS_TIMEOUT_SEC:-180}"
GPS_INTERVAL_SEC="${GPS_INTERVAL_SEC:-2}"

log() {
    printf '%s [%s] %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$SCRIPT_NAME" "$*"
}

warn() {
    log "WARN: $*"
}

error() {
    log "ERROR: $*"
}

read_status_value() {
    local raw

    if [ ! -r "$GPS_STATUS_PATH" ]; then
        return 1
    fi

    raw="$(head -n 1 "$GPS_STATUS_PATH" 2>/dev/null || true)"
    printf '%s' "$raw" | tr -d '\r\n'
    return 0
}

main() {
    local elapsed=0
    local current_value

    log "Starting GPS lock gate (DRY_RUN=$DRY_RUN path=$GPS_STATUS_PATH expected=$GPS_LOCK_VALUE timeout=${GPS_TIMEOUT_SEC}s)"

    if [ ! -r "$GPS_STATUS_PATH" ] && [ "$DRY_RUN" = "1" ]; then
        warn "GPS status path not readable in dry-run ($GPS_STATUS_PATH); continuing"
        return 0
    fi

    while [ "$elapsed" -lt "$GPS_TIMEOUT_SEC" ]; do
        if current_value="$(read_status_value)"; then
            if [ "$current_value" = "$GPS_LOCK_VALUE" ]; then
                log "GPS lock condition met ($GPS_STATUS_PATH=$current_value)"
                return 0
            fi
            log "GPS status is '$current_value', waiting for '$GPS_LOCK_VALUE'"
        else
            log "GPS status path not readable yet: $GPS_STATUS_PATH"
        fi

        sleep "$GPS_INTERVAL_SEC"
        elapsed=$((elapsed + GPS_INTERVAL_SEC))
    done

    if [ "$DRY_RUN" = "1" ]; then
        warn "Timeout waiting for GPS lock in dry-run; continuing"
        return 0
    fi

    error "Timeout waiting for GPS lock ($GPS_STATUS_PATH expected '$GPS_LOCK_VALUE')"
    return 1
}

main "$@"
