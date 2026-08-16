# webview — experience log

## Phase 1 (2026-08-16)

### Setup friction

- System had `git` (Homebrew) and Apple Clang via Xcode CLT, but no `cmake` or `ninja` on PATH.
- Vendored CMake 4.4.2 (macOS universal tarball) and Ninja 1.13.2 (`ninja-mac.zip`) under `temp/webview/tools/`.
- Cloned upstream `webview` tag `0.12.0` (commit `3ab4b5d`) into `temp/webview/src/webview`.

### Verification

- `cmake -G Ninja` configure on upstream source succeeded with Apple Clang 21.0.0.
- macOS runtime deps are system frameworks only: `WebKit`, `dl`.

### Trade-offs

- CMake universal binary is large (~266M extracted under `tools/`); acceptable for isolated `temp/webview/` layout.
- Compiler/SDK remain system-provided (CLT); not duplicated into `temp/`.

## Phase 2 (2026-08-16)

### Implementation

- C++11 single-file app (`main.cpp`) using header-only `webview::core` via `add_subdirectory` on the phase-1 source tree.
- Shared root `index.html` copied byte-for-byte into `implementations/webview/index.html` and bundled under `Contents/Resources/`.
- Loads HTML with `webview::webview::navigate("file://…/Resources/index.html")`.
- CMake `MACOSX_BUNDLE` produces `hello-world.app`; `build.sh` copies it to `temp/webview/HelloWorld.app`.

### Build friction

- Upstream emits three `-Wdeprecated-literal-operator` warnings from `webview.h` on Apple Clang 21; harmless for this build.
- No upstream macOS `.app` example; bundle layout (`Info.plist`, Resources copy, `_NSGetExecutablePath`) is manual but straightforward.

### Size optimization

- Release with `-Os`, LTO (`CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE`), hidden visibility, and `strip -x` post-link.
- Result `.app` is **80 KB** on disk (`du -sk`); runtime WebKit comes from the OS, not the bundle.

### Reproducibility

- `./implementations/webview/build.sh` runs `setup-deps.sh`, syncs HTML, configures Ninja release for `arm64`, builds, and stages the app under `temp/webview/HelloWorld.app`.
