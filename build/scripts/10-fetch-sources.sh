#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=./lib.sh
. "$SCRIPT_DIR/lib.sh"

fetch_repo() {
    local repo_url="$1"
    local dest="$2"
    local ref="$3"

    if [ ! -d "$dest/.git" ]; then
        log "Cloning $repo_url -> $dest"
        run_cmd git clone --depth 1 --branch "$ref" "$repo_url" "$dest"
    fi

    log "Fetching updates in $dest"
    run_cmd git -C "$dest" fetch --depth 1 origin "$ref"
    log "Checking out $ref in $dest"
    run_cmd git -C "$dest" checkout "$ref"
}

main() {
    load_versions
    ensure_dirs

    local src_root="$REPO_ROOT/$SRC_ROOT"
    local linux_src="$src_root/linux"
    local firmware_src="$src_root/firmware"
    local ardupilot_src="$src_root/ardupilot"

    fetch_repo "$RPI_LINUX_REPO" "$linux_src" "$RPI_LINUX_BRANCH"
    fetch_repo "$RPI_FIRMWARE_REPO" "$firmware_src" "$RPI_FIRMWARE_REF"
    fetch_repo "$ARDUPILOT_REPO" "$ardupilot_src" "$ARDUPILOT_TAG"

    log "Source fetch complete"
}

main "$@"
