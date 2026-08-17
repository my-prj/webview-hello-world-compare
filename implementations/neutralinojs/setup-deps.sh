#!/usr/bin/env bash
# Reproduce phase-1 dependencies into temp/neutralinojs/ from a clean checkout.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMPL="$ROOT/implementations/neutralinojs"
TEMP="$ROOT/temp/neutralinojs"
BINARY_VERSION="6.9.0"
BINARY_TAG="v${BINARY_VERSION}"
BINARY_ZIP="neutralinojs-${BINARY_TAG}.zip"
BINARY_URL="https://github.com/neutralinojs/neutralinojs/releases/download/${BINARY_TAG}/${BINARY_ZIP}"
MAC_ARM64_BINARY="neutralino-mac_arm64"
# Pristine size of neutralino-mac_arm64 in neutralinojs v6.9.0 release zip.
MAC_ARM64_BINARY_SIZE=2905720

mkdir -p "$TEMP/downloads" "$TEMP/bin" "$TEMP/npm"

download() {
  local url="$1"
  local dest="$2"
  if [[ -f "$dest" ]]; then
    echo "exists: $dest"
    return 0
  fi
  curl -fsSL -o "$dest" "$url"
}

download "$BINARY_URL" "$TEMP/downloads/${BINARY_ZIP}"

if [[ ! -x "$TEMP/bin/${MAC_ARM64_BINARY}" ]] \
  || [[ "$(stat -f%z "$TEMP/bin/${MAC_ARM64_BINARY}")" != "$MAC_ARM64_BINARY_SIZE" ]]; then
  rm -f "$TEMP/bin/${MAC_ARM64_BINARY}"
  rm -rf "$TEMP/.extract-binaries"
  mkdir -p "$TEMP/.extract-binaries"
  unzip -q -o "$TEMP/downloads/${BINARY_ZIP}" -d "$TEMP/.extract-binaries"
  install -m 755 "$TEMP/.extract-binaries/${MAC_ARM64_BINARY}" "$TEMP/bin/${MAC_ARM64_BINARY}"
  rm -rf "$TEMP/.extract-binaries"
fi

if [[ ! -x "$TEMP/npm/node_modules/.bin/neu" ]]; then
  cp "$IMPL/package.json" "$IMPL/package-lock.json" "$TEMP/npm/"
  npm ci --prefix "$TEMP/npm"
fi

export PATH="$TEMP/npm/node_modules/.bin:$PATH"

node --version
npm --version
neu version
file "$TEMP/bin/${MAC_ARM64_BINARY}"
ls -lh "$TEMP/downloads/${BINARY_ZIP}" "$TEMP/bin/${MAC_ARM64_BINARY}"
ls -lh "$TEMP/npm/node_modules/@neutralinojs/neu/package.json" \
  "$TEMP/npm/node_modules/@neutralinojs/lib/package.json"
