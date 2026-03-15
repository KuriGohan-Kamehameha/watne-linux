# Day 6: ROS 2 Compatible Package Integration Notes

Date: 2026-03-15
Workspace: watne-linux
Scope: Prepare ROS 2 package set for bootable image integration with compatibility gating

## Objective

Prepare a ROS 2 package set that can be integrated into the image build without breaking image creation when package availability differs across target rootfs and architecture.

## Files changed

- `build/manifests/packages-ros2.txt` (new)
- `build/scripts/36-install-ros2.sh`
- `navio2-gates/artifacts/day6-ros2-validation.log` (new evidence log)

## What was implemented

1. Added a dedicated ROS package manifest:
   - `build/manifests/packages-ros2.txt`
   - Uses `${ROS2_DISTRO}` placeholders so it tracks `build/config/versions.env`.

2. Updated ROS install step to consume the manifest:
   - Parses manifest lines with comment and whitespace stripping.
   - Expands `${ROS2_DISTRO}` placeholders into concrete package names.

3. Added compatibility filtering before install:
   - For each desired package, runs `apt-cache show <pkg>` inside chroot.
   - Installs only packages visible in apt metadata for active target.
   - Logs unavailable packages and continues safely.

4. Preserved bootable-image resilience:
   - If no compatible ROS packages are found, the build logs warning and continues.
   - If install transaction fails, script logs warning and continues.

## ROS package set prepared

Manifest contains the following package templates:

- `ros-${ROS2_DISTRO}-ros-base`
- `ros-${ROS2_DISTRO}-geometry-msgs`
- `ros-${ROS2_DISTRO}-nav-msgs`
- `ros-${ROS2_DISTRO}-sensor-msgs`
- `ros-${ROS2_DISTRO}-tf2`
- `ros-${ROS2_DISTRO}-tf2-ros`
- `ros-${ROS2_DISTRO}-tf2-tools`
- `ros-${ROS2_DISTRO}-diagnostic-updater`
- `ros-${ROS2_DISTRO}-launch`
- `ros-${ROS2_DISTRO}-launch-ros`
- `ros-${ROS2_DISTRO}-cv-bridge`
- `ros-${ROS2_DISTRO}-image-transport`

## Evidence of workings

Validation commands executed in workspace:

```bash
bash -n build/scripts/36-install-ros2.sh
grep -nE "packages-ros2.txt|wanted_pkgs|apt-cache show|Installing compatible ROS packages" build/scripts/36-install-ros2.sh
sed -n '1,220p' build/manifests/packages-ros2.txt
```

Raw command transcript saved at:

- `navio2-gates/artifacts/day6-ros2-validation.log`

Observed key output:

- Script syntax check passed (`bash -n` exit code 0).
- Manifest wiring points present in installer at expected locations:
  - `local ros_manifest="$REPO_ROOT/build/manifests/packages-ros2.txt"`
  - `wanted_pkgs` parsing array
  - `apt-cache show` compatibility probe loop
  - `Installing compatible ROS packages:` install log
- Manifest rendered with expected ROS package templates.

## Compatibility strategy summary

Compatibility is determined at build-time inside the target chroot after ROS apt source is added.
Only packages resolvable in current apt metadata are selected for installation.
This minimizes risk of blocking bootable image assembly due to unavailable ROS binary packages.

## Recommended on Linux builder (next verification)

1. `DRY_RUN=1 ALLOW_NON_LINUX=1 bash build/scripts/run-build.sh`
2. Real build: `bash build/scripts/run-build.sh`
3. Confirm ROS selection logs from `build/scripts/36-install-ros2.sh` in build logs:
   - unavailable package list (if any)
   - final compatible package install list
