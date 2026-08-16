#!/usr/bin/env bash
# Build unsigned release .app for Apple Silicon (arm64).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMPL="$ROOT/implementations/webui"
BUILD_DIR="$ROOT/temp/webui/build-release"
APP_OUT="$ROOT/temp/webui/HelloWorld.app"
WEBUI_SRC="$ROOT/temp/webui/src/webui"
WEBUI_LIB="$WEBUI_SRC/dist/libwebui-2-static.a"

"$IMPL/setup-deps.sh"

if ! cmp -s "$ROOT/index.html" "$IMPL/index.html"; then
  cp "$ROOT/index.html" "$IMPL/index.html"
fi

mkdir -p "$BUILD_DIR"

clang++ -std=c++17 \
  -arch arm64 \
  -Os -DNDEBUG \
  -flto \
  -fvisibility=hidden \
  -fvisibility-inlines-hidden \
  -I"$WEBUI_SRC/include" \
  "$IMPL/main.cpp" \
  "$WEBUI_LIB" \
  -lpthread -lm \
  -framework Cocoa -framework WebKit \
  -Wl,-dead_strip \
  -o "$BUILD_DIR/hello-world"

strip -x "$BUILD_DIR/hello-world"

rm -rf "$APP_OUT"
mkdir -p "$APP_OUT/Contents/MacOS" "$APP_OUT/Contents/Resources"

cp "$IMPL/Info.plist" "$APP_OUT/Contents/Info.plist"
cp "$BUILD_DIR/hello-world" "$APP_OUT/Contents/MacOS/hello-world"
cp "$IMPL/index.html" "$APP_OUT/Contents/Resources/index.html"

echo "Built: $APP_OUT"
du -sk "$APP_OUT"
