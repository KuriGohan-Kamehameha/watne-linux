# Day 6: ArduPilot GPIO_Sysfs libgpiod Patch Notes

Date: 2026-03-15
Workspace: watne-linux
Scope: ArduPilot Linux HAL GPIO compatibility hardening for sysfs GPIO deprecation risk

## Why this patch exists

`GPIO_Sysfs` in ArduPilot relied on `/sys/class/gpio/*` export/value files only.
That path is marked obsolete in modern kernels and can disappear in future releases.

This patch adds libgpiod support while keeping sysfs fallback behavior so current images keep working.

## Files changed

- `build/work/src/ardupilot/Tools/ardupilotwaf/cxx_checks.py`
- `build/work/src/ardupilot/Tools/ardupilotwaf/boards.py`
- `build/work/src/ardupilot/libraries/AP_HAL_Linux/GPIO_Sysfs.h`
- `build/work/src/ardupilot/libraries/AP_HAL_Linux/GPIO_Sysfs.cpp`

Note: this workspace snapshot only contains `Tools/` and `libraries/AP_HAL_Linux/` under
`build/work/src/ardupilot/`; no top-level `wscript` file exists here.

## Build-system changes

1. Added waf probe:
   - `check_libgpiod(cfg, env)` in `cxx_checks.py`
   - Uses pkg-config package `libgpiod`
   - Detects API generation and sets one of:
     - `HAVE_LIBGPIOD_V2`
     - `HAVE_LIBGPIOD_V1`

2. Linux board configuration now calls:
   - `cfg.check_libgpiod(env)`

3. Session hardening (2026-03-15):
   - `check_libgpiod()` now uses `getattr(cfg.options, 'disable_libgpiod', False)`.
   - This avoids configure-time attribute errors in trimmed trees where the command-line
     option is not defined.

4. If your full ArduPilot checkout includes top-level waf option registration,
   define `--disable-libgpiod` there to expose explicit CLI control.

## Evidence of workings (this session)

The following code paths were inspected and verified in this workspace:

1. `GPIO_Sysfs` compile-time enablement:
   - `GPIO_Sysfs.h` guards libgpiod support behind
     `HAVE_LIBGPIOD_V1 || HAVE_LIBGPIOD_V2` and includes `<gpiod.h>`.

2. Backend runtime implementation:
   - `GPIO_Sysfs.cpp` implements `_gpiod_init()`, `_gpiod_set_mode()`, `_gpiod_read()`,
     `_gpiod_write()`, and `_gpiod_release_line()`.
   - `read/write/pinMode/channel` use libgpiod when available and fall back to sysfs.

3. Linux board wiring:
   - `boards.py` Linux `configure_env()` calls `cfg.check_libgpiod(env)`.

4. Waf detection logic:
   - `cxx_checks.py` probes package `libgpiod` and checks v2 API first, then v1 API.

5. Hardening patch applied now:
   - Updated `cxx_checks.py` to safely read the optional disable flag with `getattr(...)`.

## Runtime behavior changes in GPIO_Sysfs

1. Backend selection:
   - If libgpiod is detected at build time and gpiochip metadata can be discovered at runtime,
     GPIO ops use libgpiod.
   - Otherwise, code falls back to legacy sysfs behavior.

2. Mapping strategy:
   - Global GPIO number is mapped to chip and line offset using:
     - `/sys/class/gpio/gpiochip*/base`
     - `/sys/class/gpio/gpiochip*/ngpio`
     - `/dev/gpiochipN`

3. DigitalSource path:
   - `DigitalSource_Sysfs` now delegates reads/writes/mode through backend-aware helpers.
   - This avoids hard dependency on a sysfs `value` fd when libgpiod is active.

4. libgpiod API support:
   - v1 path: `gpiod_chip_get_line`, `gpiod_line_request_input/output`, `gpiod_line_get/set_value`
   - v2 path: line settings/config/request objects with `gpiod_chip_request_lines`

## Known limitations and caveats

1. Runtime mapping still reads gpiochip metadata from sysfs class entries.
   - If a future kernel removes those class entries entirely, mapping logic must move to a pure
     gpiochip-info path.

2. This patch does not alter non-GPIO_Sysfs Linux HAL subsystems.

3. The fallback model is intentional:
   - libgpiod failure on one pin does not hard-fail the process; it falls back to sysfs path.

## Successor validation checklist

Run on target Linux board (Navio2 image):

1. Configure/build with default behavior (libgpiod enabled when present):
   - `./waf configure --board navio2`
   - `./waf copter`

2. Confirm configure probes:
   - Look for messages mentioning:
     - `Checking for 'libgpiod'`
     - `Checking for libgpiod v2 API` or `v1 API`

3. GPIO smoke test (board dependent pin selection):
   - Use ArduPilot GPIO test or direct autopilot startup path that toggles GPIO.
   - Confirm no fatal errors if sysfs export path is unavailable.

4. Force fallback test:
   - If your waf options expose it: `./waf configure --board navio2 --disable-libgpiod`
   - If not exposed in your tree: remove/override libgpiod dev package visibility and rebuild
     to force sysfs fallback path.
   - Rebuild and verify old sysfs behavior still works.

5. Regression checks:
   - RC input and PWM-related gate scripts in `navio2-gates/scripts/`
   - Existing gate artifacts format and scripts should remain unchanged.

## Suggested next hardening task

Move global GPIO mapping off sysfs class files and onto chip line metadata,
so libgpiod path survives a full sysfs GPIO class removal scenario.

## Successor handoff commands

Run these from `build/work/src/ardupilot` in a full checkout:

1. `rg -n "check_libgpiod|HAVE_LIBGPIOD|gpiod_" Tools libraries/AP_HAL_Linux`
2. `./waf configure --board navio2`
3. `./waf copter`
4. `./waf configure --board navio2 --disable-libgpiod` (if option exists)
5. `./waf copter`

Expected outcome:

- libgpiod-enabled build compiles and runs GPIO through gpiod backend when chips are present.
- fallback build compiles and runs through legacy sysfs path.

## Navio2 gate follow-up: `rcio_adc` / `rcio_pwm` availability

Date: 2026-03-15

`navio2-gates/scripts/navio2-modules.sh` now treats `modprobe rcio_adc` and
`modprobe rcio_pwm` as best-effort by default.

Rationale:

- Some kernels expose equivalent functionality with built-in drivers or different
   packaging, where `modprobe` can fail despite usable runtime paths.
- Startup gates should fail on missing functional interfaces, not only on module
   insertion mechanics.

Behavior:

1. Gate attempts to load modules listed in `REQUIRED_MODULES`.
2. If load fails and `MODULE_LOAD_STRICT=0` (default), gate logs WARN and proceeds.
3. Gate still enforces `MODULE_EXPECTED_PATHS` as hard requirements in live mode.
4. Set `MODULE_LOAD_STRICT=1` to restore hard-fail on any module load error.

This keeps RCIO ADC/PWM checks robust across kernel packaging differences while
preserving strict path-based readiness enforcement.
