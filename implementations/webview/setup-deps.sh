#!/usr/bin/env bash
# Reproduce phase-1 dependencies into temp/webview/ from a clean checkout.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMP="$ROOT/temp/webview"
CMAKE_VERSION="4.4.2"
NINJA_VERSION="1.13.2"
WEBVIEW_TAG="0.12.0"

mkdir -p "$TEMP/downloads" "$TEMP/tools" "$TEMP/src"

download() {
  local url="$1"
  local dest="$2"
  if [[ -f "$dest" ]]; then
    echo "exists: $dest"
    return 0
  fi
  curl -fsSL -o "$dest" "$url"
}

download \
  "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-macos-universal.tar.gz" \
  "$TEMP/downloads/cmake-${CMAKE_VERSION}-macos-universal.tar.gz"

download \
  "https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-mac.zip" \
  "$TEMP/downloads/ninja-mac.zip"

if [[ ! -d "$TEMP/tools/cmake/CMake.app" ]]; then
  tar -xzf "$TEMP/downloads/cmake-${CMAKE_VERSION}-macos-universal.tar.gz" -C "$TEMP/tools"
  rm -rf "$TEMP/tools/cmake"
  mv "$TEMP/tools/cmake-${CMAKE_VERSION}-macos-universal" "$TEMP/tools/cmake"
fi

if [[ ! -x "$TEMP/tools/ninja/ninja" ]]; then
  mkdir -p "$TEMP/tools/ninja"
  unzip -q -o "$TEMP/downloads/ninja-mac.zip" -d "$TEMP/tools/ninja"
  chmod +x "$TEMP/tools/ninja/ninja"
fi

if [[ ! -d "$TEMP/src/webview/.git" ]]; then
  git clone --depth 1 --branch "$WEBVIEW_TAG" https://github.com/webview/webview.git "$TEMP/src/webview"
fi

export PATH="$TEMP/tools/cmake/CMake.app/Contents/bin:$TEMP/tools/ninja:$PATH"
cmake --version
ninja --version
git -C "$TEMP/src/webview" describe --tags --always
