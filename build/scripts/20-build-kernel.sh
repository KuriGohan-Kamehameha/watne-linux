#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=./lib.sh
. "$SCRIPT_DIR/lib.sh"

main() {
    load_versions
    ensure_dirs

    local linux_src="$REPO_ROOT/$SRC_ROOT/linux"
    local out_dir="$REPO_ROOT/$OUT_ROOT/kernel/$CANDIDATE_ID"
    local build_dir="$out_dir/build"
    local artifacts_dir="$out_dir/artifacts"

    [ -d "$linux_src" ] || die "Linux source not found. Run 10-fetch-sources.sh first."

    mkdir -p "$build_dir" "$artifacts_dir"

    log "Kernel build start for candidate $CANDIDATE_ID"
    log "Source: $linux_src"
    log "Build dir: $build_dir"

    local make_env=(
        "ARCH=$TARGET_ARCH"
        "CROSS_COMPILE=$CROSS_COMPILE"
        "KBUILD_OUTPUT=$build_dir"
        "LOCALVERSION=$KERNEL_LOCALVERSION"
    )

    run_cmd env "${make_env[@]}" "${MAKE_BIN:-make}" -C "$linux_src" "$KERNEL_DEFCONFIG"
    run_cmd env "${make_env[@]}" "${MAKE_BIN:-make}" -C "$linux_src" -j"$KERNEL_JOBS" "$KERNEL_IMAGE_NAME" modules dtbs
    run_cmd env "${make_env[@]}" "${MAKE_BIN:-make}" -C "$linux_src" INSTALL_MOD_PATH="$artifacts_dir/modules" modules_install

    run_cmd cp "$build_dir/arch/arm64/boot/$KERNEL_IMAGE_NAME" "$artifacts_dir/"

    log "Kernel build complete. Artifacts in $artifacts_dir"
}

main "$@"
