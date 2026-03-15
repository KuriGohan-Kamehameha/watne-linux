#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="run-gates"
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
RUN_GATES_CONTINUE_ON_FAIL="${RUN_GATES_CONTINUE_ON_FAIL:-1}"

log() {
    printf '%s [%s] %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$SCRIPT_NAME" "$*"
}

error() {
    log "ERROR: $*"
}

main() {
    local failures=0
    local results=""
    local gate
    local gate_path

    log "Starting gate runner (DRY_RUN=$DRY_RUN continue_on_fail=$RUN_GATES_CONTINUE_ON_FAIL)"

    for gate in \
        navio2-modules.sh \
        navio2-permissions.sh \
        navio2-time-sync.sh \
        navio2-gps-lock.sh \
        navio2-preflight.sh
    do
        gate_path="$SCRIPT_DIR/$gate"

        if [ ! -x "$gate_path" ]; then
            error "Gate script is missing or not executable: $gate_path"
            results="${results}${gate}:MISSING\n"
            failures=$((failures + 1))
            if [ "$RUN_GATES_CONTINUE_ON_FAIL" != "1" ]; then
                break
            fi
            continue
        fi

        log "Running $gate"
        if "$gate_path"; then
            results="${results}${gate}:PASS\n"
        else
            results="${results}${gate}:FAIL\n"
            failures=$((failures + 1))
            if [ "$RUN_GATES_CONTINUE_ON_FAIL" != "1" ]; then
                break
            fi
        fi
    done

    log "Gate summary:"
    printf '%b' "$results"

    if [ "$failures" -gt 0 ]; then
        error "Gate runner completed with $failures failure(s)"
        return 1
    fi

    log "All gates passed"
    return 0
}

main "$@"
