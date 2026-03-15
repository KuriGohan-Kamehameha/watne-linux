# Navio2 Startup Gates Scaffold

This scaffold provides practical startup gates for Navio2 systems and a one-command runner. It is designed for systemd-based Linux targets and assumes root execution for hardware checks and permission changes.

## Included

- Gate scripts in `scripts/`
- Default environment file in `env/navio2-gates.env`
- systemd oneshot services in `systemd/`
- Example ArduPilot override in `systemd/ardupilot.service.override.example`

## Gate Sequence

1. `navio2-modules.sh`: attempts required module loads and verifies key Navio2 paths.
2. `navio2-permissions.sh`: applies group and mode to required device/sysfs paths.
3. `navio2-time-sync.sh`: waits for `timedatectl` synchronization.
4. `navio2-gps-lock.sh`: polls GPS status path/value until lock or timeout.
5. `navio2-preflight.sh`: validates ADC readability, preflight log write, and optional SPI node.

`run-gates.sh` runs all gates sequentially and returns non-zero if any gate fails.

## Installation

1. Copy scripts:

```bash
sudo install -d /usr/local/lib/navio2-gates
sudo install -m 0755 scripts/*.sh /usr/local/lib/navio2-gates/
```

2. Copy environment file:

```bash
sudo install -d /etc/default
sudo install -m 0644 env/navio2-gates.env /etc/default/navio2-gates
```

3. Install systemd units:

```bash
sudo install -d /etc/systemd/system
sudo install -m 0644 systemd/navio2-*.service /etc/systemd/system/
```

4. Optionally gate ArduPilot startup with the provided override example:

```bash
sudo install -d /etc/systemd/system/ardupilot.service.d
sudo install -m 0644 systemd/ardupilot.service.override.example /etc/systemd/system/ardupilot.service.d/override.conf
```

5. Reload systemd and enable/start services:

```bash
sudo systemctl daemon-reload
sudo systemctl enable navio2-modules.service navio2-permissions.service navio2-time-sync.service navio2-gps-lock.service navio2-preflight.service
sudo systemctl start navio2-modules.service navio2-permissions.service navio2-time-sync.service navio2-gps-lock.service navio2-preflight.service
```

## One-Command Runner

Run gates manually in sequence:

```bash
sudo /usr/local/lib/navio2-gates/run-gates.sh
```

Check status quickly:

```bash
sudo /usr/local/lib/navio2-gates/navio2-gate-status.sh
```

## Dry Run

Set `DRY_RUN=1` in `/etc/default/navio2-gates` to avoid hard-failing on missing Navio2 paths while validating service flow.

## Notes

- In normal mode (`DRY_RUN=0`), required missing paths fail the gate.
- In dry-run mode, missing Navio2 paths are warnings.
- Module load attempts for `rcio_adc` / `rcio_pwm` are best-effort by default (`MODULE_LOAD_STRICT=0`) to tolerate kernels where drivers are built-in or not loadable as modules.
- Set `MODULE_LOAD_STRICT=1` to hard-fail on any `modprobe` failure.
- Tune thresholds and paths in `/etc/default/navio2-gates`.
