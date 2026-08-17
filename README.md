# WEBVIEW HELLO WORLD COMPARE

## GOAL

Compare selected ways to build a macOS desktop application with WebView using the same minimal Hello World application. The focus is on the smallest practical unsigned Apple Silicon application bundle.

## RESULT

| Project | Result `.app` | Required native language | License |
| --- | --- | --- | --- |
| [webview/webview](https://github.com/webview/webview) | 80 KB | C++11 | MIT |
| [Saucer](https://github.com/saucer/saucer) | 336 KB | C++23 | MIT |
| [WebUI](https://github.com/webui-dev/webui) | 220 KB | C++17 | MIT |
| [Neutralinojs](https://github.com/neutralinojs/neutralinojs) | 2,824 KB | — | MIT |
| [Tauri](https://github.com/tauri-apps/tauri) | 2,228 KB | Rust | Apache-2.0 OR MIT |

Every implementation uses the same shared HTML/CSS input. **Required native language** is the additional non-web language in which the evaluated integration was actually written; `—` means no native application code was needed. It does not describe the language used to implement the WebView tool itself.

The [detailed report](COMPARISON.md) describes the methodology, all measurements, dependencies, CI runs, and practical notes.
