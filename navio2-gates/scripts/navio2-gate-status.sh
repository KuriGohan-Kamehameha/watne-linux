#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="navio2-gate-status"
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
RCIO_ADC_DIR="${RCIO_ADC_DIR:-/sys/kernel/rcio/adc}"
PWMCHIP_PATH="${PWMCHIP_PATH:-/sys/class/pwm/pwmchip0}"
SPI_NODE="${SPI_NODE:-/dev/spidev0.0}"
GPS_STATUS_PATH="${GPS_STATUS_PATH:-/run/navio2/gps_status}"

log() {
    printf '%s [%s] %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$SCRIPT_NAME" "$*"
}

path_state() {
    local path="$1"
    if [ -e "$path" ]; then
        printf 'present'
    else
        printf 'missing'
    fi
}

service_state() {
    local unit="$1"

    if ! command -v systemctl >/dev/null 2>&1; then
        printf 'systemctl-unavailable'
        return 0
    fi

    if systemctl is-active --quiet "$unit"; then
        printf 'active'
    elif systemctl is-failed --quiet "$unit"; then
        printf 'failed'
    else
        printf 'inactive'
    fi
}

main() {
    log "Gate status snapshot (DRY_RUN=$DRY_RUN env=$ENV_FILE)"
    printf 'path %-32s : %s\n' "$RCIO_ADC_DIR" "$(path_state "$RCIO_ADC_DIR")"
    printf 'path %-32s : %s\n' "$PWMCHIP_PATH" "$(path_state "$PWMCHIP_PATH")"
    printf 'path %-32s : %s\n' "$SPI_NODE" "$(path_state "$SPI_NODE")"
    printf 'path %-32s : %s\n' "$GPS_STATUS_PATH" "$(path_state "$GPS_STATUS_PATH")"

    printf 'service %-29s : %s\n' 'navio2-modules.service' "$(service_state navio2-modules.service)"
    printf 'service %-29s : %s\n' 'navio2-permissions.service' "$(service_state navio2-permissions.service)"
    printf 'service %-29s : %s\n' 'navio2-time-sync.service' "$(service_state navio2-time-sync.service)"
    printf 'service %-29s : %s\n' 'navio2-gps-lock.service' "$(service_state navio2-gps-lock.service)"
    printf 'service %-29s : %s\n' 'navio2-preflight.service' "$(service_state navio2-preflight.service)"
}

main "$@"
