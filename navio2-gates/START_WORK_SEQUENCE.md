# START_WORK_SEQUENCE

1. Day 0 (G1, G2)
   - Task 1: Validate workspace baseline (`README.md`, `env/navio2-gates.env`, `scripts/`, `systemd/`) and record host OS/date.
   - Task 2: Verify executable bits and shell syntax for all scripts in `scripts/`.
   - Stop condition: If any required file is missing or script syntax fails, stop and open a blocker ticket before Day 1.
   - End-of-day deliverables: Baseline checklist complete; script inventory with pass/fail state.
   - Evidence artifacts: `artifacts/day0-baseline.txt`, `artifacts/day0-shellcheck.txt`.

2. Day 1 (G3, G4)
   - Task 1: Validate `scripts/navio2-modules.sh` and `scripts/navio2-permissions.sh` behavior in a dry run.
   - Task 2: Validate `systemd/navio2-modules.service` and `systemd/navio2-permissions.service` unit correctness (`ExecStart`, dependencies, restart policy).
   - Stop condition: If module load or permission setup cannot be reproduced cleanly, stop and resolve root cause before Day 2.
   - End-of-day deliverables: Module and permission gates marked pass/fail with remediation notes.
   - Evidence artifacts: `artifacts/day1-modules.log`, `artifacts/day1-permissions.log`, `artifacts/day1-systemd-units.txt`.

3. Day 2 (G5, G6)
   - Task 1: Validate `scripts/navio2-time-sync.sh` and `systemd/navio2-time-sync.service` with expected timeout and retry behavior.
   - Task 2: Validate `scripts/navio2-gps-lock.sh` and `systemd/navio2-gps-lock.service` lock criteria and failure handling.
   - Stop condition: If time sync or GPS lock cannot reach defined success criteria, stop and do not proceed to preflight validation.
   - End-of-day deliverables: Time sync and GPS lock acceptance results with measured timings.
   - Evidence artifacts: `artifacts/day2-time-sync.log`, `artifacts/day2-gps-lock.log`, `artifacts/day2-timing.csv`.

4. Day 3 (G7, G8)
   - Task 1: Validate `scripts/navio2-preflight.sh` gate checks and return codes for pass/fail paths.
   - Task 2: Validate `systemd/navio2-preflight.service` ordering against prior gates and confirm deterministic startup sequence.
   - Stop condition: If preflight returns false pass or non-deterministic failures, stop and fix validation logic before orchestration testing.
   - End-of-day deliverables: Preflight gate truth table and startup ordering report.
   - Evidence artifacts: `artifacts/day3-preflight-matrix.csv`, `artifacts/day3-systemd-order.txt`.

5. Day 4 (G9, G10)
   - Task 1: Validate orchestration flow in `scripts/run-gates.sh` including fail-fast and exit propagation.
   - Task 2: Validate observability output in `scripts/navio2-gate-status.sh` for each gate state (pending/pass/fail).
   - Stop condition: If orchestration does not fail fast on blocker gates or status output is ambiguous, stop before final signoff.
   - End-of-day deliverables: End-to-end gate runner validated with known good and known bad scenarios.
   - Evidence artifacts: `artifacts/day4-run-gates-pass.log`, `artifacts/day4-run-gates-fail.log`, `artifacts/day4-status-snapshots.txt`.

6. Day 5 (G11, G12)
   - Task 1: Execute full cold-boot rehearsal and confirm all gates complete in sequence without manual intervention.
   - Task 2: Publish release-ready operational notes (runbook, rollback trigger, owner handoff) and lock baseline artifacts.
   - Stop condition: If any gate regresses from previous passing evidence, stop release and open rollback plan immediately.
   - End-of-day deliverables: Final go/no-go decision, signed checklist, handoff package.
   - Evidence artifacts: `artifacts/day5-full-rehearsal.log`, `artifacts/day5-go-no-go.md`, `artifacts/day5-handoff.md`.
