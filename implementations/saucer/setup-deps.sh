#!/usr/bin/env bash
# Reproduce phase-1 dependencies into temp/saucer/ from a clean checkout.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMP="$ROOT/temp/saucer"
CMAKE_VERSION="4.4.2"
NINJA_VERSION="1.13.2"
SAUCER_TAG="v8.0.5"
CPM_VERSION="0.41.0"

mkdir -p "$TEMP/downloads" "$TEMP/tools" "$TEMP/src" "$TEMP/cpm-cache"

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

if [[ ! -d "$TEMP/src/saucer/.git" ]]; then
  git clone --depth 1 --branch "$SAUCER_TAG" https://github.com/saucer/saucer.git "$TEMP/src/saucer"
fi

export PATH="$TEMP/tools/cmake/CMake.app/Contents/bin:$TEMP/tools/ninja:$PATH"
export CPM_SOURCE_CACHE="$TEMP/cpm-cache"

cmake --version
ninja --version
git -C "$TEMP/src/saucer" describe --tags --always

# Prefetch CPM.cmake itself and saucer transitive git dependencies via configure.
PREFETCH_BUILD="$TEMP/prefetch-build"
if [[ ! -f "$PREFETCH_BUILD/CMakeCache.txt" ]]; then
  cmake -S "$TEMP/src/saucer" -B "$PREFETCH_BUILD" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -Dsaucer_examples=OFF \
    -Dsaucer_tests=OFF \
    -Dsaucer_backend=WebKit
fi

echo "CPM cache entries:"
find "$TEMP/cpm-cache" -mindepth 1 -maxdepth 2 -type d 2>/dev/null | sort || true
