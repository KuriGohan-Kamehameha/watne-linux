#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="navio2-preflight"
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
ADC_CHANNELS="${ADC_CHANNELS:-0 1 2 3 4 5}"
ADC_PATH_PREFIX="${ADC_PATH_PREFIX:-${RCIO_ADC_DIR:-/sys/kernel/rcio/adc}/ch}"
PREFLIGHT_LOG_FILE="${PREFLIGHT_LOG_FILE:-/var/log/navio2-preflight.log}"
PREFLIGHT_REQUIRE_SPI="${PREFLIGHT_REQUIRE_SPI:-0}"
SPI_NODE="${SPI_NODE:-/dev/spidev0.0}"

log() {
    printf '%s [%s] %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$SCRIPT_NAME" "$*"
}

warn() {
    log "WARN: $*"
}

error() {
    log "ERROR: $*"
}

check_adc_channel() {
    local channel="$1"
    local adc_path="${ADC_PATH_PREFIX}${channel}"
    local adc_value

    if [ ! -r "$adc_path" ]; then
        if [ "$DRY_RUN" = "1" ]; then
            warn "ADC channel path not readable in dry-run: $adc_path"
            return 0
        fi
        error "ADC channel path not readable: $adc_path"
        return 1
    fi

    adc_value="$(cat "$adc_path" 2>/dev/null || true)"
    if [ -z "$adc_value" ]; then
        if [ "$DRY_RUN" = "1" ]; then
            warn "ADC channel read empty in dry-run: $adc_path"
            return 0
        fi
        error "ADC channel read failed: $adc_path"
        return 1
    fi

    log "ADC ch${channel} read ok: ${adc_value}"
    return 0
}

check_log_write() {
    local log_dir

    log_dir="$(dirname -- "$PREFLIGHT_LOG_FILE")"

    if [ "$DRY_RUN" = "1" ]; then
        log "DRY_RUN: would write preflight marker to $PREFLIGHT_LOG_FILE"
        return 0
    fi

    if ! mkdir -p "$log_dir"; then
        error "Failed to create log directory: $log_dir"
        return 1
    fi

    if ! printf '%s [%s] preflight log write test\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$SCRIPT_NAME" >>"$PREFLIGHT_LOG_FILE"; then
        error "Failed to append to preflight log: $PREFLIGHT_LOG_FILE"
        return 1
    fi

    log "Preflight log write test passed: $PREFLIGHT_LOG_FILE"
    return 0
}

check_optional_spi() {
    if [ "$PREFLIGHT_REQUIRE_SPI" = "1" ]; then
        if [ -e "$SPI_NODE" ]; then
            log "SPI node present: $SPI_NODE"
            return 0
        fi

        if [ "$DRY_RUN" = "1" ]; then
            warn "SPI node missing in dry-run: $SPI_NODE"
            return 0
        fi

        error "SPI node required but missing: $SPI_NODE"
        return 1
    fi

    if [ -e "$SPI_NODE" ]; then
        log "Optional SPI node present: $SPI_NODE"
    else
        warn "Optional SPI node not present: $SPI_NODE"
    fi

    return 0
}

main() {
    local failures=0
    local channel

    log "Starting preflight gate (DRY_RUN=$DRY_RUN)"

    for channel in $ADC_CHANNELS; do
        if ! check_adc_channel "$channel"; then
            failures=$((failures + 1))
        fi
    done

    if ! check_log_write; then
        failures=$((failures + 1))
    fi

    if ! check_optional_spi; then
        failures=$((failures + 1))
    fi

    if [ "$failures" -gt 0 ]; then
        error "Preflight gate failed with $failures issue(s)"
        return 1
    fi

    log "Preflight gate passed"
    return 0
}

main "$@"
