# neutralinojs — experience log

## Phase 1 (2026-08-16)

See `manifest.json` for pinned versions and download weight (~24M under `temp/neutralinojs/` at phase 1; ~28M after phase 2 build artifacts).

### Setup friction

- Framework release zip uses the `v` prefix in the filename (`neutralinojs-v6.9.0.zip`), matching neu CLI's `{tag}` substitution — easy to miss when hand-crafting URLs.
- `neu update` expects a project directory with `neutralino.config.json`; phase 1 downloads the official release zip directly instead of stubbing app files.
- Node.js and npm are system prerequisites (not vendored); neu CLI and `@neutralinojs/lib` install locally under `temp/neutralinojs/npm/` via `npm ci`.

## Phase 2 (2026-08-16)

Reproduce: `./implementations/neutralinojs/build.sh` → `temp/neutralinojs/HelloWorld.app` (2840 KB via `du -sk`).

### Implementation

- Minimal `neutralino.config.json`: local static server only (`enableServer: true`), no native API (`enableNativeAPI: false`), logging disabled, single window mode.
- Shared root `index.html` copied byte-for-byte to `resources/index.html`.
- Release build: `neu build --release --embed-resources --clean` with arm64 binary symlinked from `temp/neutralinojs/bin/`.
- Output wrapped in a standard macOS bundle (`Info.plist` + `Contents/MacOS/hello-world`) for consistent `HelloWorld.app` layout with other implementations.

### Size optimization

- `--embed-resources` injects `resources.neu` into the Mach-O binary (~2820 KB executable); neu removes the external `resources.neu` after embedding.
- No `neutralino.js` client, icons, CSS, or extra modes in resources — only the shared HTML file.
- Inspector and file logging disabled in config.

### Build friction

- `neu build --macos-bundle` renames all three macOS binary variants (`mac_x64`, `mac_arm64`, `mac_universal`) unconditionally; it fails if phase 1 only extracted `neutralino-mac_arm64`. Workaround: skip `--macos-bundle` and wrap the arm64 binary in `HelloWorld.app` manually in `build.sh`.
- `distributionPath` in config points to `temp/neutralinojs/dist` so build artifacts stay under `temp/`.
- Dev iteration: `cd implementations/neutralinojs && neu run` (uses `bin/neutralino-mac_arm64` symlink and live resources).

### Runtime notes

- Framework runtime uses system WebKit; no extra runtime bundled beyond the Neutralino binary with embedded resources.
- GUI smoke test via `open` was not reliable in the agent shell (Launch Services error 163); direct execution and `neu run` start successfully.
