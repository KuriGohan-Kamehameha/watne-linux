#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="navio2-modules"
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
REQUIRED_MODULES="${REQUIRED_MODULES:-rcio_adc rcio_pwm}"
MODULE_EXPECTED_PATHS="${MODULE_EXPECTED_PATHS:-${RCIO_ADC_DIR:-/sys/kernel/rcio/adc} ${PWMCHIP_PATH:-/sys/class/pwm/pwmchip0} ${SPI_NODE:-/dev/spidev0.0}}"
MODULE_LOAD_STRICT="${MODULE_LOAD_STRICT:-0}"

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

has_command() {
    command -v "$1" >/dev/null 2>&1
}

is_module_loaded() {
    local module="$1"

    if [ -d "/sys/module/${module}" ]; then
        return 0
    fi

    if has_command lsmod && lsmod | awk '{print $1}' | grep -Fxq "$module"; then
        return 0
    fi

    return 1
}

module_is_known() {
    local module="$1"

    if ! has_command modinfo; then
        return 2
    fi

    if modinfo "$module" >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

check_required_path() {
    local path="$1"
    if [ -e "$path" ]; then
        log "Verified path: $path"
        return 0
    fi

    if [ "$DRY_RUN" = "1" ]; then
        warn "Missing expected Navio2 path in dry-run: $path"
        return 0
    fi

    error "Missing required Navio2 path: $path"
    return 1
}

main() {
    local failures=0
    local mod
    local path
    local known_state

    log "Starting module gate (DRY_RUN=$DRY_RUN strict_load=$MODULE_LOAD_STRICT)"

    for mod in $REQUIRED_MODULES; do
        if is_module_loaded "$mod"; then
            log "Module already loaded: $mod"
            continue
        fi

        log "Loading module: $mod"
        if run_cmd modprobe "$mod"; then
            continue
        fi

        if [ "$DRY_RUN" = "1" ]; then
            warn "Dry-run ignored module load failure for: $mod"
            continue
        fi

        if [ "$MODULE_LOAD_STRICT" = "1" ]; then
            error "Failed to load module in strict mode: $mod"
            failures=$((failures + 1))
            continue
        fi

        if is_module_loaded "$mod"; then
            warn "modprobe failed but module appears loaded: $mod"
            continue
        fi

        known_state="unknown"
        if module_is_known "$mod"; then
            known_state="yes"
        else
            case "$?" in
                1)
                    known_state="no"
                    ;;
                *)
                    known_state="unknown"
                    ;;
            esac
        fi

        case "$known_state" in
            yes)
                warn "Module available but modprobe failed for: $mod (continuing; path checks enforce readiness)"
                ;;
            no)
                warn "Module not available as loadable module on this kernel: $mod (continuing)"
                ;;
            *)
                warn "Unable to determine module availability for: $mod (modinfo unavailable; continuing)"
                ;;
        esac
    done

    if [ -z "$REQUIRED_MODULES" ]; then
        warn "No modules configured in REQUIRED_MODULES"
    fi

    for path in $MODULE_EXPECTED_PATHS; do
        if ! check_required_path "$path"; then
            failures=$((failures + 1))
        fi
    done

    if [ "$failures" -gt 0 ]; then
        error "Module gate failed with $failures issue(s)"
        return 1
    fi

    log "Module gate passed"
    return 0
}

main "$@"
