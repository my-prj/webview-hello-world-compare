# saucer — experience log

## Phase 1 (2026-08-16)

See `manifest.json` for dependency versions and download weight (~385M under `temp/saucer/`).

## Phase 2 (2026-08-16)

### Implementation

- C++23 coroutine app (`main.cpp`) using `saucer::smartview` with WebKit backend via `add_subdirectory` on the phase-1 source tree.
- Shared root `index.html` copied byte-for-byte into `implementations/saucer/index.html` and bundled under `Contents/Resources/`.
- Loads HTML with `saucer::url::from(bundle_path)` + `webview->set_url(...)`.
- CMake `MACOSX_BUNDLE` produces `hello-world.app`; `build.sh` copies it to `temp/saucer/HelloWorld.app`.

### Build friction

- Saucer pulls 11 transitive CPM git deps (coco, glaze, lockpp, …); first configure is slow, rebuild uses `CPM_SOURCE_CACHE`.
- Harmless CMake warnings about Package-Config when `nontype_functional` is in the dependency graph (same as phase 1 prefetch).
- Requires C++23 and OBJCXX; Apple Clang 21 builds cleanly.
- No upstream macOS `.app` example; bundle layout (`Info.plist`, Resources copy, `_NSGetExecutablePath`) is manual, same pattern as `webview`.

### Size optimization

- Release with `-Os`, LTO, hidden visibility, and `strip -x` post-link.
- Static link of `libsaucer.a` plus Glaze serializer; Result `.app` is **336 KB** on disk (`du -sk`); binary alone ~328 KB.
- Runtime WebKit/Cocoa/CoreImage come from the OS, not the bundle.

### Reproducibility

- `./implementations/saucer/build.sh` runs `setup-deps.sh`, syncs HTML, configures Ninja release for `arm64`, builds, and stages the app under `temp/saucer/HelloWorld.app`.

## Phase 3 (2026-08-16)

### GitHub Actions

- Workflow: `.github/workflows/saucer.yml` on `macos-latest` (`macos-26-arm64`, release `20260728.0273`).
- Mirrors local contract: `setup-deps.sh` → `build.sh` → `du -sk` → zip artifact.
- Pushed in commit `75008c9`.

### Previous attempt (rolled back)

- Run [31960312213](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31960312213) — **cancelled** after ~45 min in GHA queue; prior DevOps session interrupted (~34 min wall time including queue — not a reliable T3).

### CI results

- Successful run: [31963292986](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31963292986).
- T3 (DevOps session): **6 s** — workflow setup and push only; no GHA queue/run wait.
- T4 (job): **74 s**; Result `.app`: **336 KB** (matches local); zip artifact: 116 KB.
- Runner: macOS 26.5.2, AppleClang 21.0.0; vendored CMake 4.4.2, Ninja 1.13.2, saucer v8.0.5.
