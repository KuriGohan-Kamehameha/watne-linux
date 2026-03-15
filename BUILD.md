# Navio2 Build Kickoff

This workspace now includes a first-pass build scaffold for a custom Navio2 image.

## Goals
- Pin versions and build inputs.
- Keep artifacts reproducible by candidate ID.
- Run build steps in a strict sequence.

## Layout
- `build/config/versions.env`: pinned versions and build knobs.
- `build/manifests/packages-core.txt`: required runtime packages.
- `build/manifests/packages-optional.txt`: optional tooling.
- `build/scripts/`: sequential build scripts.
- `build/work/`: generated output and source checkouts.

## Quick Start
1. Review and edit `build/config/versions.env`.
2. Run prerequisite checks:
   - `bash build/scripts/00-prereq-check.sh`
3. Fetch sources:
   - `bash build/scripts/10-fetch-sources.sh`
4. Build kernel:
   - `bash build/scripts/20-build-kernel.sh`
5. Run the orchestrator:
   - `bash build/scripts/run-build.sh`

## Dry-Run Scaffold Mode
Use this mode on macOS/non-Linux hosts to validate script flow without compiling:
- `DRY_RUN=1 ALLOW_NON_LINUX=1 bash build/scripts/run-build.sh`

## Real Build Host Requirements
- Linux host (or Linux VM/runner).
- GNU Make >= 4 (set `MAKE_BIN` in `build/config/versions.env` if needed).
- Case-sensitive filesystem for kernel source checkouts.
- AArch64 cross compiler in `PATH` matching `CROSS_COMPILE`.

## Notes
- The rootfs and image assembly steps are intentionally conservative and expect a Linux builder.
- On macOS hosts, use a Linux VM or Linux runner for full image creation.
