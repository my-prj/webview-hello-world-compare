#!/usr/bin/env bash
# Build unsigned release .app for Apple Silicon (arm64).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMPL="$ROOT/implementations/neutralinojs"
TEMP="$ROOT/temp/neutralinojs"
DIST="$TEMP/dist"
APP_OUT="$TEMP/HelloWorld.app"
MAC_ARM64_BINARY="neutralino-mac_arm64"
BUILD_BINARY="hello-world-mac_arm64"

"$IMPL/setup-deps.sh"

if ! cmp -s "$ROOT/index.html" "$IMPL/resources/index.html"; then
  cp "$ROOT/index.html" "$IMPL/resources/index.html"
fi

mkdir -p "$IMPL/bin"
ln -sf "$TEMP/bin/${MAC_ARM64_BINARY}" "$IMPL/bin/${MAC_ARM64_BINARY}"

export PATH="$TEMP/npm/node_modules/.bin:$PATH"

cd "$IMPL"
neu build --release --embed-resources --clean

BUILT_BINARY="$DIST/hello-world/${BUILD_BINARY}"
if [[ ! -f "$BUILT_BINARY" ]]; then
  echo "error: release binary not found at $BUILT_BINARY" >&2
  exit 1
fi

rm -rf "$APP_OUT"
mkdir -p "$APP_OUT/Contents/MacOS"
cp "$BUILT_BINARY" "$APP_OUT/Contents/MacOS/hello-world"
cp "$IMPL/Info.plist" "$APP_OUT/Contents/Info.plist"
chmod +x "$APP_OUT/Contents/MacOS/hello-world"

echo "Built: $APP_OUT"
du -sk "$APP_OUT"
