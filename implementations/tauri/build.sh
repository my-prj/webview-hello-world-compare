#!/usr/bin/env bash
# Build unsigned release .app for Apple Silicon (arm64).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMPL="$ROOT/implementations/tauri"
TEMP="$ROOT/temp/tauri"
APP_OUT="$TEMP/HelloWorld.app"
BUNDLE_DIR="$TEMP/target/aarch64-apple-darwin/release/bundle/macos"

"$IMPL/setup-deps.sh"

if ! cmp -s "$ROOT/index.html" "$IMPL/dist/index.html" 2>/dev/null; then
  mkdir -p "$IMPL/dist"
  cp "$ROOT/index.html" "$IMPL/dist/index.html"
fi

export RUSTUP_HOME="$TEMP/rustup"
export CARGO_HOME="$TEMP/cargo"
export CARGO_TARGET_DIR="$TEMP/target"
export PATH="$CARGO_HOME/bin:$TEMP/npm/node_modules/.bin:$PATH"
unset CI

cd "$IMPL"
tauri build --target aarch64-apple-darwin

BUILT_APP="$BUNDLE_DIR/HelloWorld.app"
if [[ ! -d "$BUILT_APP" ]]; then
  echo "error: .app bundle not found at $BUILT_APP" >&2
  exit 1
fi

rm -rf "$APP_OUT"
cp -R "$BUILT_APP" "$APP_OUT"

echo "Built: $APP_OUT"
du -sk "$APP_OUT"
