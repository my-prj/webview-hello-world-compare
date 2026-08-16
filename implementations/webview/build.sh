#!/usr/bin/env bash
# Build unsigned release .app for Apple Silicon (arm64).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMPL="$ROOT/implementations/webview"
BUILD_DIR="$ROOT/temp/webview/build-release"
APP_OUT="$ROOT/temp/webview/HelloWorld.app"

"$IMPL/setup-deps.sh"

if ! cmp -s "$ROOT/index.html" "$IMPL/index.html"; then
  cp "$ROOT/index.html" "$IMPL/index.html"
fi

export PATH="$ROOT/temp/webview/tools/cmake/CMake.app/Contents/bin:$ROOT/temp/webview/tools/ninja:$PATH"

cmake -G Ninja \
  -B "$BUILD_DIR" \
  -S "$IMPL" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_ARCHITECTURES=arm64

cmake --build "$BUILD_DIR"

BUILT_APP="$(find "$BUILD_DIR" -maxdepth 2 -name '*.app' -type d | head -n 1)"
if [[ -z "$BUILT_APP" ]]; then
  echo "error: .app bundle not found under $BUILD_DIR" >&2
  exit 1
fi

rm -rf "$APP_OUT"
cp -R "$BUILT_APP" "$APP_OUT"

echo "Built: $APP_OUT"
du -sk "$APP_OUT"
