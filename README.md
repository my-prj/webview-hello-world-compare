# WEBVIEW HELLO WORLD COMPARE

## GOAL

Compare selected ways to build a macOS desktop application with WebView, using the same deliberately minimal Hello World application in every implementation.

The comparison focuses on developer experience, language and dependency footprint, and the smallest practical unsigned application bundle produced by GitHub Actions for Apple Silicon.

## RESULT

| Project | Link | Result `.app` | Languages | Dependencies | Notes |
| --- | --- | --- | --- | --- | --- |
| webview/webview | https://github.com/webview/webview | TBD | TBD | TBD | TBD |
| Saucer | https://github.com/saucer/saucer | TBD | TBD | TBD | TBD |
| WebUI | https://github.com/webui-dev/webui | TBD | TBD | TBD | TBD |
| Neutralinojs | https://github.com/neutralinojs/neutralinojs | TBD | TBD | TBD | TBD |
| Tauri | https://github.com/tauri-apps/tauri | TBD | TBD | TBD | TBD |

`Result .app` is the size of the final uncompressed `.app` bundle. Each implementation should additionally publish a downloadable release archive containing that bundle; archive size may be recorded in Notes but is not the primary comparison metric.

## RULES

- Target platform: macOS on Apple Silicon (`arm64`) only.
- Each implementation presents the same Hello World screen, centered both vertically and horizontally in its application window.
- The application must contain no functionality beyond rendering that screen, except what the chosen tool requires to launch it.
- Builds run exclusively in GitHub Actions on an Apple Silicon macOS runner. Record the runner image and tool versions used.
- Build a release configuration with size optimization enabled where the tool supports it, while retaining the normal runtime dependencies required by the application.
- Do not require code signing, notarization, an Apple Developer account, or distribution outside GitHub Releases.
- The primary size metric is the on-disk size of the final `.app` bundle after the build. Do not use `.dmg` or `.pkg` as the primary metric: they measure packaging choices rather than the application itself.
- A `.zip` archive of the `.app` may be published only to make the artifact downloadable. Its compressed size is secondary and must be labelled as such.
- Keep each implementation as small and idiomatic as practical. Document material build flags, external tooling, and runtime dependencies.
- Compare developer experience qualitatively: setup complexity, dependency burden, clarity of the implementation, build reliability, and ease of iteration.
