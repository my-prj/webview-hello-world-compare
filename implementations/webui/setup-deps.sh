#!/usr/bin/env bash
# Reproduce phase-1 dependencies into temp/webui/ from a clean checkout.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMP="$ROOT/temp/webui"
WEBUI_TAG="2.5.0-beta.3"

mkdir -p "$TEMP/src"

if [[ ! -d "$TEMP/src/webui/.git" ]]; then
  git clone --depth 1 --branch "$WEBUI_TAG" https://github.com/webui-dev/webui.git "$TEMP/src/webui"
fi

export CC=clang
export ARCH_TARGET=arm64

WEBUI_SRC="$TEMP/src/webui"
LIB_STATIC="$WEBUI_SRC/dist/libwebui-2-static.a"

if [[ ! -f "$LIB_STATIC" ]]; then
  make -C "$WEBUI_SRC" -f GNUmakefile ARCH_TARGET=arm64 release
fi

clang --version
git -C "$WEBUI_SRC" describe --tags --always
git -C "$WEBUI_SRC" rev-parse HEAD
ls -lh "$WEBUI_SRC/dist/" "$LIB_STATIC"
