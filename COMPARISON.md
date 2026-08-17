# Detailed comparison report

## Scope

This report compares selected approaches for building a macOS desktop application with WebView. Each implementation renders the same minimal, versioned `index.html` file and produces an unsigned release application for Apple Silicon (`arm64`).

The final measurements come from successful GitHub Actions builds. The primary size metric is the uncompressed `.app` bundle; the `.zip` size is provided only as a download-packaging reference.

## Detailed results

| Project | Result `.app` | Result `.zip` | T1 | T2 | T3 | T4 | Integration language | Tool core | Dependency weight | Dependencies | Experience | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [webview/webview](https://github.com/webview/webview) | 80 KB | 20 KB | 294s | 34s | 620s | 25s | C++11 | C/C++ | ~364 MB | webview 0.12.0 (header-only); vendored CMake 4.4.2 + Ninja 1.13.2 | [Notes](implementations/webview/EXPERIENCE.md) | runner `macos-26-arm64` (20260728.0273), macOS 26.5.2, AppleClang 21.0.0; [CI run](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31959767420) |
| [Saucer](https://github.com/saucer/saucer) | 336 KB | 116 KB | 302s | 240s | 6s | 74s | C++23 | C++ | ~418 MB | saucer 8.0.5 + 11 CPM git deps; vendored CMake 4.4.2 + Ninja 1.13.2 | [Notes](implementations/saucer/EXPERIENCE.md) | runner `macos-26-arm64` (20260728.0273), macOS 26.5.2, AppleClang 21.0.0; build.sh 16s; [CI run](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31963292986); prior run [31960312213](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31960312213) cancelled (GHA queue) |
| [WebUI](https://github.com/webui-dev/webui) | 220 KB | 84 KB | 41s | 480s | 33s | 18s | C++17 | C/C++ | ~14 MB | webui 2.5.0-beta.3 (static library); no vendored CMake or Ninja | [Notes](implementations/webui/EXPERIENCE.md) | runner `macos-26-arm64` (20260728.0273), macOS 26.5.2, AppleClang 21.0.0; build.sh 1s; prior run [31962557483](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31962557483) cancelled (GHA queue on `macos-26-arm64` label); [CI run](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31986445523) |
| [Neutralinojs](https://github.com/neutralinojs/neutralinojs) | 2,824 KB | 872 KB | 78s | 900s | 195s | 21s | — | C++ | ~28 MB | neutralinojs 6.9.0 + neu CLI 11.7.2 | [Notes](implementations/neutralinojs/EXPERIENCE.md) | runner `macos-26-arm64` (20260728.0273), macOS 26.5.2, Node v24.18.0; build.sh 2s; local `.app` 2,840 KB; [CI run](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31963765822) |
| [Tauri](https://github.com/tauri-apps/tauri) | 2,228 KB | 1,144 KB | 768s | 278s | 157s | 123s | Rust | Rust | ~2.2 GB | tauri 2.11.5 + CLI 2.11.4 + Rust 1.96.0 | [Notes](implementations/tauri/EXPERIENCE.md) | runner `macos-26-arm64` (20260728.0273), macOS 26.5.2, AppleClang 21.0.0, Rust 1.96.0, Node v24.18.0; build.sh 37s; [CI run](https://github.com/my-prj/webview-hello-world-compare/actions/runs/31964923436) |

## Metrics

| Column | Meaning | How measured |
| --- | --- | --- |
| Project | Implementation identifier and upstream project | Stable slug in `implementations/<slug>/`; project name links to upstream repository |
| Result `.app` | Final uncompressed application bundle size | `du -sk <path-to>.app` on the CI artifact from phase 3; primary size metric |
| Result `.zip` | Compressed `.app` archive published for download | `du -sk <path-to>.zip` on the CI artifact from phase 3; packaging reference only |
| T1 | Setup and dependency acquisition time | Subagent session wall time for phase 1, including retries and waits |
| T2 | Implementation time | Subagent session wall time for phase 2, including development, debugging, and local release builds |
| T3 | DevOps setup time | Subagent session wall time for phase 3 through the final workflow status |
| T4 | GitHub Actions build duration | GitHub Actions job duration for the successful CI run |
| Integration language | Additional non-web language used in the evaluated application implementation | Inspected application source; common, byte-identical HTML/CSS input, build scripts, and declarative configuration excluded |
| Tool core | Main implementation language or languages of the WebView tool | Upstream project source and documentation |
| Dependency weight | Total size of downloaded dependencies and toolchains | Measured under `temp/<slug>/` after phase 1 |
| Dependencies | Dependency types and versions | Versions recorded in `manifest.json` |
| Experience | Practical implementation notes | `implementations/<slug>/EXPERIENCE.md` |
| Notes | Context not covered by other columns | Blockers, prior attempts, and CI-run links |

T1–T3 were recorded as total wall time of separate Cursor Composer 2.5 (`composer-2.5-fast`) subagent sessions. Network, build, retry, and queue time are included. Sizes are recorded in kilobytes from `du -sk`.

## Methodology

### Shared application input

- The repository-root `index.html` is the only shared application input.
- Every implementation copies it byte-for-byte and adds no content beyond what is necessary to render and launch it.
- Each approach is isolated in `implementations/<slug>/`; its dependencies, caches, and build output are isolated in `temp/<slug>/`.

### Build contract

- Target: macOS on Apple Silicon (`arm64`).
- Output: unsigned, size-optimised release `.app`; code signing, notarisation, and external distribution are out of scope.
- GitHub Actions is the standard measurement path for final artifacts. A `.zip` may accompany the artifact for download but is not the primary size measurement.

### Phases

1. **Setup and dependencies (T1).** Download all dependencies, compilers, CLIs, and SDK components into `temp/<slug>/`; record versions and total weight.
2. **Implementation (T2).** Copy the shared HTML input, develop and debug as needed, and create an unsigned local release `.app`.
3. **DevOps (T3, T4).** Configure GitHub Actions for the same build contract and record successful-run duration and tooling facts.

Each phase must complete before the next starts. Interrupted phases are rolled back and restarted from scratch so that incomplete work cannot affect the result.

### Evaluation principles

Prefer objective metrics—application size, time, dependency weight, and build reliability. Qualitative notes cover setup complexity, clarity, and ease of iteration where useful.
