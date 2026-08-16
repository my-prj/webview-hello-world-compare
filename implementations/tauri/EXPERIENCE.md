# tauri — experience log

## Phase 1 (2026-08-16)

See `manifest.json` for pinned versions and download weight under `temp/tauri/`.

### Setup friction

- Tauri 2.x requires Rust, Node.js, and macOS Command Line Tools; only Rust toolchain and `@tauri-apps/cli` are vendored under `temp/tauri/`.
- Rust installs via rustup into isolated `RUSTUP_HOME` / `CARGO_HOME` under `temp/tauri/`; `aarch64-apple-darwin` target added for release builds.
- `@tauri-apps/cli` npm package ships prebuilt binaries; no separate `cargo install tauri-cli` needed for phase 1.
- Application crates (`tauri`, `tauri-build`, etc.) are fetched during phase 2 when the project is created and built.

## Phase 2 (2026-08-16)

Reproduce: `./implementations/tauri/build.sh` → `temp/tauri/HelloWorld.app` (2228 KB via `du -sk`).

### Implementation

- Minimal Tauri 2 app: `tauri::Builder::default()` with no plugins or custom commands.
- Shared root `index.html` copied byte-for-byte to `dist/index.html`; `frontendDist` points at `../dist` (Tauri rejects a dist folder that includes `src-tauri`).
- Release build via `tauri build --target aarch64-apple-darwin`; bundle copied to `temp/tauri/HelloWorld.app`.
- Build artifacts and Cargo registry cache stay under `temp/tauri/` via `CARGO_TARGET_DIR`, `CARGO_HOME`, and `RUSTUP_HOME`.

### Size optimization

- Cargo `[profile.release]`: `opt-level = "z"`, `lto = true`, `strip = true`, `codegen-units = 1`, `panic = "abort"`.
- `tauri` dependency with `default-features = false` and empty feature list.
- Bundle target limited to `app` (no `.dmg`).
- Minimal RGBA icon set (~29 KB `.icns`); no extra CSS, JS, or assets beyond shared HTML.

### Build friction

- `tauri-build` crate version (2.6.3) does not match `tauri` crate version (2.11.5) on crates.io; pin each to its latest available version.
- Tauri icon PNGs must be RGBA; RGB greyscale PNGs fail at `generate_context!` compile time.
- `CI=1` in the environment breaks `tauri build` (`invalid value '1' for '--ci'`); `build.sh` unsets `CI`.
- With `--target aarch64-apple-darwin`, the `.app` lands under `target/aarch64-apple-darwin/release/bundle/macos/`, not `target/release/bundle/macos/`.
- First release compile pulls ~428 crates and adds ~736 MB under `temp/tauri/target/`; incremental rebuild ~37 s.

### Runtime notes

- Unsigned `.app` bundles successfully; WebKit provided by macOS.
- Release binary ~2184 KB (`du -sk` on `Contents/MacOS/hello-world`).
