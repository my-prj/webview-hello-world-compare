# WEBVIEW HELLO WORLD COMPARE

## GOAL

Compare selected ways to build a macOS desktop application with WebView, using the same deliberately minimal Hello World application in every implementation.

The comparison focuses on developer experience, language and dependency footprint, and the smallest practical unsigned application bundle produced by GitHub Actions for Apple Silicon.

## RESULT

| Project | Link | Result `.app` | Languages | Dependencies | Notes |
| --- | --- | --- | --- | --- | --- |
| webview/webview | https://github.com/webview/webview | 80 KB | C++11 | webview 0.12.0 (header-only); vendored CMake 4.4.2 + Ninja 1.13.2 (~364M under `temp/webview/`) | T1=294s, T2=34s, T3=620s, T4=25s; runner `macos-26-arm64` (20260728.0273), macOS 26.5.2, AppleClang 21.0.0; artifact zip 20 KB; [CI run](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31959767420) |
| Saucer | https://github.com/saucer/saucer | 336 KB | C++23, Objective-C++ | saucer 8.0.5 + 11 CPM git deps; vendored CMake 4.4.2 + Ninja 1.13.2 (~418M under `temp/saucer/`) | T1=302s, T2=240s (build.sh 16s), T3=6s, T4=74s; runner `macos-26-arm64` (20260728.0273), macOS 26.5.2, AppleClang 21.0.0; artifact zip 116 KB; [CI run](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31963292986); prior run [31960312213](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31960312213) cancelled (GHA queue) |
| WebUI | https://github.com/webui-dev/webui | 220 KB local, CI pending | C++17 | webui 2.5.0-beta.3 (static lib); ~14M under `temp/webui/` (no vendored CMake/Ninja) | T1=41s, T2=480s, T3=33s, T4 pending; local `.app` 220 KB; CI pending; [CI run](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31962557483) |
| Neutralinojs | https://github.com/neutralinojs/neutralinojs | 2824 KB | JSON, HTML | neutralinojs 6.9.0 + neu CLI 11.7.2; ~28M under `temp/neutralinojs/` | T1=78s, T2=2s (build.sh), T3=195s, T4=21s; runner `macos-26-arm64` (20260728.0273), macOS 26.5.2, Node v24.18.0; artifact zip 872 KB; local `.app` 2840 KB; [CI run](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31963765822) |
| Tauri | https://github.com/tauri-apps/tauri | 2228 KB local, CI pending | Rust, HTML, JSON | tauri 2.11.5 + CLI 2.11.4 + Rust 1.96.0; ~2.2G under `temp/tauri/` | T1=768s, T2=278s (build.sh 37s), T3 pending, T4 pending; local `.app` 2228 KB; CI pending |

`Result .app` is the size of the final uncompressed `.app` bundle. Each implementation should additionally publish a downloadable release archive containing that bundle; archive size may be recorded in Notes but is not the primary comparison metric.

## RULES

### Shared application input

- The repository root contains `index.html`, the single shared HTML file that defines the Hello World screen
- That file shows one line of text, centered vertically and horizontally
- Every implementation must copy this file byte-for-byte; it is not a reference design to reimplement
- Do not add extra assets, styling, or content beyond what is required to display that HTML file

### Repository layout

- Keep each tool in an isolated implementation directory under `implementations/<slug>/`
- Use these stable slugs consistently: `webview`, `saucer`, `webui`, `neutralinojs`, `tauri`
- Store downloaded dependencies, toolchains, caches, build outputs, and other reconstructible files under `temp/<slug>/`
- Do not share implementation-specific files, caches, dependencies, or build outputs between slugs
- The only shared input across implementations is the versioned root `index.html` file

### Platform and build output

- Target platform: macOS on Apple Silicon (`arm64`) only
- The application must contain no functionality beyond rendering the shared Hello World screen, except what the chosen tool requires to launch it
- Build a release configuration with size optimization enabled where the tool supports it, while retaining the normal runtime dependencies required by the application
- Do not require code signing, notarization, an Apple Developer account, or distribution outside GitHub Releases
- The primary size metric is the on-disk size of the final uncompressed `.app` bundle
- Do not use `.dmg` or `.pkg` as the primary metric; they measure packaging choices rather than the application itself
- A `.zip` archive of the `.app` may be published only to make the artifact downloadable; its compressed size is secondary and must be labelled as such
- Keep each implementation as small and idiomatic as practical; document material build flags, external tooling, and runtime dependencies

### Agent pipeline

Run three subagents per slug, in order. Start the next slug only after all three phases of the current slug succeed. Use only **Cursor Composer 2.5** (`composer-2.5-fast`) for every subagent.

**Phase 1 — setup and dependencies**

- Pull all required dependencies, compilers, CLIs, and SDK components into `temp/<slug>/`
- Finish only when every required component is fully downloaded and ready to use
- Record objective facts: what was installed, actual versions, and total downloaded weight under `temp/<slug>/`
- Do not write application code or produce a `.app`

**Phase 2 — implementation**

- Copy the shared root HTML file byte-for-byte
- Use dependencies prepared in phase 1
- Perform dev and debug builds as needed during development
- Produce an unsigned local release `.app` on Apple Silicon
- Apply initial size optimization where the tool supports it
- Do not configure GitHub Actions

**Phase 3 — DevOps**

- Configure GitHub Actions for the same unsigned release build contract used locally
- Builds run on an Apple Silicon macOS runner; record the runner image and actual tool versions used
- Finish only when the workflow run reaches a final success or failure state with a clear diagnosis
- GitHub Actions is the standardized measurement path for final artifacts; local dev and debug builds remain part of phase 2

### Session completion and rollback

- A subagent session ends only when its phase definition of done is fully complete, including waits for downloads, builds, uploads, and other uncontrollable delays
- Long sessions are expected
- If a subagent session is interrupted before completion, roll back all work from that phase completely
- Start the same phase again with a new subagent from scratch
- Do not resume, continue, or recover work from the interrupted attempt
- Remove temporary artifacts from that phase so the next subagent cannot discover or reuse them
- Revert tracked repository changes from the failed attempt before restarting the phase

### Versions and reproducibility

- Start each phase with the latest stable versions available on the run date, chosen from upstream documentation
- After a successful phase, record the actual versions that worked in tracked project files
- Keep enough information in Git to reproduce every experiment deterministically from a clean checkout

### Metrics

Measure these objective values for every slug:

| Metric | Meaning | Source |
| --- | --- | --- |
| T1 | Setup and dependency acquisition time, including all retries and waits | Subagent session wall time for phase 1 |
| T2 | Implementation time, including dev, debug, and local release builds | Subagent session wall time for phase 2 |
| T3 | DevOps setup time through final workflow status | Subagent session wall time for phase 3 |
| T4 | GitHub Actions build duration | GitHub Actions run data |
| Result `.app` | Final uncompressed application bundle size | CI artifact from phase 3 |

- Measure Result `.app` with `du -sk <path-to>.app` and report the size in kilobytes
- Do not split agent time from network, build, or waiting overhead; total wall time is the metric
- Record T1–T4 in the result table Notes column unless separate timing columns are added later
- Dependency and toolchain weight belong in the Dependencies column or Notes when measured

### Result table columns

- **Link**: upstream project repository
- **Result `.app`**: final uncompressed `.app` size from CI
- **Languages**: languages used in the implementation plus any required runtime
- **Dependencies**: concise summary of dependency types and measured toolchain or download weight when available
- **Notes**: T1–T4, runner image, actual tool versions, local preview size, blockers, and attempt count

### Experience log

- Subjective experience notes are useful but secondary to objective metrics
- No strict template is required; uneven quality across implementations is acceptable
- Each implementation may keep its own notes file if the agent finds that helpful

### Evaluation priority

- Prefer objective, non-falsifiable measurements such as time, dependency weight, and `.app` size
- Compare developer experience qualitatively when useful: setup complexity, dependency burden, clarity of the implementation, build reliability, and ease of iteration
