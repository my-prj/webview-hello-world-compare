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
RESOURCES_NEU="resources.neu"

"$IMPL/setup-deps.sh"

if ! cmp -s "$ROOT/index.html" "$IMPL/resources/index.html"; then
  cp "$ROOT/index.html" "$IMPL/resources/index.html"
fi

mkdir -p "$IMPL/bin"
rm -f "$IMPL/bin/${MAC_ARM64_BINARY}"
cp "$TEMP/bin/${MAC_ARM64_BINARY}" "$IMPL/bin/${MAC_ARM64_BINARY}"

export PATH="$TEMP/npm/node_modules/.bin:$PATH"

cd "$IMPL"
# --embed-resources breaks on macOS 26: dyld rejects the postject section layout.
neu build --release --clean

BUILT_BINARY="$DIST/hello-world/${BUILD_BINARY}"
BUILT_RESOURCES="$DIST/hello-world/${RESOURCES_NEU}"
if [[ ! -f "$BUILT_BINARY" ]]; then
  echo "error: release binary not found at $BUILT_BINARY" >&2
  exit 1
fi
if [[ ! -f "$BUILT_RESOURCES" ]]; then
  echo "error: resources file not found at $BUILT_RESOURCES" >&2
  exit 1
fi

rm -rf "$APP_OUT"
mkdir -p "$APP_OUT/Contents/MacOS"
cp -L "$BUILT_BINARY" "$APP_OUT/Contents/MacOS/hello-world"
chmod +x "$APP_OUT/Contents/MacOS/hello-world"
codesign --force --sign - "$APP_OUT/Contents/MacOS/hello-world"
cp "$BUILT_RESOURCES" "$APP_OUT/Contents/MacOS/${RESOURCES_NEU}"
cp "$IMPL/Info.plist" "$APP_OUT/Contents/Info.plist"

echo "Built: $APP_OUT"
du -sk "$APP_OUT"
