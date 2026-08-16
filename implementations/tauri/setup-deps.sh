#!/usr/bin/env bash
# Reproduce phase-1 dependencies into temp/tauri/ from a clean checkout.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMPL="$ROOT/implementations/tauri"
TEMP="$ROOT/temp/tauri"
RUST_TOOLCHAIN="1.96.0"

mkdir -p "$TEMP/downloads" "$TEMP/npm"

export RUSTUP_HOME="$TEMP/rustup"
export CARGO_HOME="$TEMP/cargo"
export PATH="$CARGO_HOME/bin:$TEMP/npm/node_modules/.bin:$PATH"

download() {
  local url="$1"
  local dest="$2"
  if [[ -f "$dest" ]]; then
    echo "exists: $dest"
    return 0
  fi
  curl -fsSL -o "$dest" "$url"
}

if [[ ! -x "$CARGO_HOME/bin/rustc" ]]; then
  download "https://sh.rustup.rs" "$TEMP/downloads/rustup-init.sh"
  sh "$TEMP/downloads/rustup-init.sh" -y --no-modify-path --default-toolchain "$RUST_TOOLCHAIN"
  rustup default "$RUST_TOOLCHAIN"
  rustup target add aarch64-apple-darwin
fi

if [[ ! -x "$TEMP/npm/node_modules/.bin/tauri" ]]; then
  cp "$IMPL/package.json" "$IMPL/package-lock.json" "$TEMP/npm/"
  npm ci --prefix "$TEMP/npm"
fi

rustc --version
cargo --version
rustup show active-toolchain
node --version
npm --version
tauri --version
clang --version | head -1
xcode-select -p

ls -lh "$TEMP/downloads/rustup-init.sh" 2>/dev/null || true
du -sh "$TEMP/rustup" "$TEMP/cargo" "$TEMP/npm"
