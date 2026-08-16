# webui — experience log

## Phase 1 (2026-08-16)

See `manifest.json` for dependency versions and download weight (~14M under `temp/webui/`).

Stable 2.4.2 has no macOS WKWebView sources; **2.5.0-beta.3** selected for WebView comparison.

## Phase 2 (2026-08-16)

### Implementation

- C++17 app (`main.cpp`) using `webui::window::show_wv()` with WKWebView backend.
- Shared root `index.html` copied byte-for-byte into `implementations/webui/index.html` and bundled under `Contents/Resources/`.
- `set_root_folder(bundle Resources)` + `show_wv("index.html")`; WebUI serves the file via its embedded HTTP server to WKWebView.
- `build.sh` compiles with Apple Clang (`clang++ -Os -flto`), static-links `libwebui-2-static.a`, assembles `HelloWorld.app` manually (no CMake — not vendored in phase 1).

### Build friction

- No system `cmake`/`ninja`; direct `clang++` link matches upstream GNUmakefile examples and avoids vendoring another ~360M toolchain.
- No upstream macOS `.app` example; bundle layout (`Info.plist`, Resources copy, `_NSGetExecutablePath`) is manual, same pattern as `webview`/`saucer`.
- WebUI has no `set_title()` API; WKWebView window title follows page metadata (shared HTML has no `<title>`).

### Size optimization

- Release with `-Os`, LTO, hidden visibility, `-Wl,-dead_strip`, and `strip -x` post-link.
- Static link of `libwebui-2-static.a` (336 KB library artifact; ~209 KB in final binary after LTO/strip).
- Result `.app` is **220 KB** on disk (`du -sk`); runtime WebKit/Cocoa come from the OS.

### Reproducibility

- `./implementations/webui/build.sh` runs `setup-deps.sh`, syncs HTML, builds release binary for `arm64`, and stages the app under `temp/webui/HelloWorld.app`.

## Phase 3 (2026-08-16, partial)

### GitHub Actions

- Workflow: `.github/workflows/webui.yml` on `macos-26-arm64`.
- Mirrors local contract: `setup-deps.sh` → `build.sh` → `du -sk` → zip artifact.
- No vendored CMake/Ninja in CI — same as local phase 2 (direct `clang++` + GNUmakefile for `libwebui-2-static.a`).

- Pushed in commit `9f44ab0`.

### CI status (pending)

- Run: [31962557483](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31962557483) — **queued** at time of recording.
- T3 (DevOps session): **33 s** — workflow setup and push only; no GHA queue/run wait.
- T4 and CI Result `.app`: **pending** until the workflow run completes.
