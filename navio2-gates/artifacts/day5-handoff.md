# Handoff Package

Date: 2026-03-15
Candidate: navio2-v1-alpha1

## What Was Delivered

A complete startup gate system for Navio2 hardware validation with:
- 5 sequential gate scripts (modules, permissions, time-sync, GPS lock, preflight)
- 1 orchestrator (run-gates.sh) with fail-fast and continue-on-fail modes
- 1 observability tool (navio2-gate-status.sh)
- 5 systemd oneshot units with strict ordering chain
- 1 ArduPilot service override example
- Configurable environment file with env-var override support

## How to Deploy

1. Copy scripts to `/usr/local/lib/navio2-gates/` on target
2. Copy env file to `/etc/default/navio2-gates`
3. Copy systemd units to `/etc/systemd/system/`
4. Copy ardupilot override to `/etc/systemd/system/ardupilot.service.d/override.conf`
5. Run `systemctl daemon-reload && systemctl enable navio2-modules navio2-permissions navio2-time-sync navio2-gps-lock navio2-preflight`
6. Reboot to test full gate sequence

## How to Validate

- Dry-run: `DRY_RUN=1 /usr/local/lib/navio2-gates/run-gates.sh`
- Live: `/usr/local/lib/navio2-gates/run-gates.sh`
- Status: `/usr/local/lib/navio2-gates/navio2-gate-status.sh`

## Rollback

1. `systemctl disable navio2-modules navio2-permissions navio2-time-sync navio2-gps-lock navio2-preflight`
2. Remove override from `/etc/systemd/system/ardupilot.service.d/`
3. `systemctl daemon-reload`
4. ArduPilot will start without gates on next boot

## Configuration Knobs

All settings in `/etc/default/navio2-gates` can be overridden by env-var export:
- `DRY_RUN=1` - Simulate all actions
- `GPS_TIMEOUT_SEC=60` - Shorter GPS lock timeout
- `RUN_GATES_CONTINUE_ON_FAIL=0` - Stop at first failure (default: continue)
- `PREFLIGHT_REQUIRE_SPI=1` - Make SPI check mandatory

## Artifact Inventory

| File | Day | Content |
|------|-----|---------|
| day0-baseline.txt | 0 | Workspace file inventory |
| day0-shellcheck.txt | 0 | Script syntax verification |
| day1-modules.log | 1 | Module + permission dry-run + systemd analysis |
| day1-permissions.log | 1 | Permission gate dry-run |
| day1-systemd-units.txt | 1 | Systemd unit static analysis |
| day2-time-sync.log | 2 | Time-sync validation |
| day2-gps-lock.log | 2 | GPS lock validation + bug fixes |
| day2-timing.csv | 2 | Gate timing measurements |
| day3-preflight-matrix.csv | 3 | Preflight truth table |
| day3-systemd-order.txt | 3 | Systemd startup ordering |
| day4-run-gates-pass.log | 4 | Orchestrator pass scenario |
| day4-run-gates-fail.log | 4 | Orchestrator fail scenarios |
| day4-status-snapshots.txt | 4 | Observability output |
| day5-full-rehearsal.log | 5 | Full cold-boot rehearsal |
| day5-go-no-go.md | 5 | Go/no-go decision |
| day5-handoff.md | 5 | This file |

## Owner

Handoff to target deployment team for live hardware validation.
