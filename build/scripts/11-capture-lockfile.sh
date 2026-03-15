#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=./lib.sh
. "$SCRIPT_DIR/lib.sh"

repo_ref() {
    local path="$1"
    local name="$2"
    [ -d "$path/.git" ] || die "Missing git repo: $path"
    local commit
    commit="$(git -C "$path" rev-parse HEAD)"
    printf '%s=%s\n' "$name" "$commit"
}

main() {
    load_versions
    ensure_dirs

    local src_root="$REPO_ROOT/$SRC_ROOT"
    local out_file="$REPO_ROOT/$OUT_ROOT/source-lock-$CANDIDATE_ID.env"

    mkdir -p "$(dirname "$out_file")"

    {
        printf 'CANDIDATE_ID=%s\n' "$CANDIDATE_ID"
        printf 'GENERATED_AT=%s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
        repo_ref "$src_root/linux" "RPI_LINUX_COMMIT"
        repo_ref "$src_root/firmware" "RPI_FIRMWARE_COMMIT"
        repo_ref "$src_root/ardupilot" "ARDUPILOT_COMMIT"
    } >"$out_file"

    log "Wrote source lockfile: $out_file"
}

main "$@"
