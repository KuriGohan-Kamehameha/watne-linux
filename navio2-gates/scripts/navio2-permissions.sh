#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="navio2-permissions"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
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
PERMISSIONS_GROUP="${PERMISSIONS_GROUP:-dialout}"
PERMISSIONS_MODE="${PERMISSIONS_MODE:-0660}"
PERMISSIONS_PATHS="${PERMISSIONS_PATHS:-${RCIO_ADC_DIR:-/sys/kernel/rcio/adc}/ch0 ${RCIO_ADC_DIR:-/sys/kernel/rcio/adc}/ch1 ${RCIO_ADC_DIR:-/sys/kernel/rcio/adc}/ch2 ${RCIO_ADC_DIR:-/sys/kernel/rcio/adc}/ch3 ${RCIO_ADC_DIR:-/sys/kernel/rcio/adc}/ch4 ${RCIO_ADC_DIR:-/sys/kernel/rcio/adc}/ch5 ${SPI_NODE:-/dev/spidev0.0}}"

log() {
    printf '%s [%s] %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$SCRIPT_NAME" "$*"
}

warn() {
    log "WARN: $*"
}

error() {
    log "ERROR: $*"
}

run_cmd() {
    if [ "$DRY_RUN" = "1" ]; then
        log "DRY_RUN: $*"
        return 0
    fi
    "$@"
}

main() {
    local failures=0
    local path

    log "Starting permissions gate (DRY_RUN=$DRY_RUN)"

    for path in $PERMISSIONS_PATHS; do
        if [ ! -e "$path" ]; then
            if [ "$DRY_RUN" = "1" ]; then
                warn "Missing path in dry-run: $path"
                continue
            fi
            error "Missing required path: $path"
            failures=$((failures + 1))
            continue
        fi

        log "Applying permissions to $path (group=$PERMISSIONS_GROUP mode=$PERMISSIONS_MODE)"
        if ! run_cmd chgrp "$PERMISSIONS_GROUP" "$path"; then
            if [ "$DRY_RUN" = "1" ]; then
                warn "Dry-run ignored chgrp failure on: $path"
            else
                error "chgrp failed on: $path"
                failures=$((failures + 1))
            fi
        fi

        if ! run_cmd chmod "$PERMISSIONS_MODE" "$path"; then
            if [ "$DRY_RUN" = "1" ]; then
                warn "Dry-run ignored chmod failure on: $path"
            else
                error "chmod failed on: $path"
                failures=$((failures + 1))
            fi
        fi
    done

    if [ "$failures" -gt 0 ]; then
        error "Permissions gate failed with $failures issue(s)"
        return 1
    fi

    log "Permissions gate passed"
    return 0
}

main "$@"
