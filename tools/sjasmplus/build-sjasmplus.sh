#!/bin/sh
# Rebuilds the vendored sjasmplus binaries from the upstream release tag.
#
#   tools/sjasmplus/build-sjasmplus.sh [all|macos|linux-x64|linux-arm64|windows-x64]
#
# macos        on a Mac: one universal binary (arm64 + x86_64), macOS 11 and later
# linux-*      in Docker (Alpine, musl): static binaries that run on any Linux distribution
# windows-x64  in Docker (Debian, MinGW-w64): a static sjasmplus.exe
#
# Every binary is built with Lua (the build scripts of this project use it). Needs git; Docker for the Linux and
# Windows builds; Xcode command line tools for macOS. SJASMPLUS_REPO / SJASMPLUS_TAG override the source.
set -eu

TAG=${SJASMPLUS_TAG:-v1.23.1}
REPO=${SJASMPLUS_REPO:-https://github.com/z00m128/sjasmplus.git}
HERE=$(cd "$(dirname "$0")" && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
TARGET=${1:-all}

echo "sjasmplus $TAG from $REPO"
git -c advice.detachedHead=false clone --quiet --depth 1 --recurse-submodules --shallow-submodules --branch "$TAG" "$REPO" "$WORK/src"
JOBS=$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)

build_macos() {
    echo "== macos (universal)"
    cp -R "$WORK/src" "$WORK/macos"
    make -C "$WORK/macos" -j"$JOBS" \
        CC="clang -arch arm64 -arch x86_64 -mmacosx-version-min=11.0" \
        CXX="clang++ -arch arm64 -arch x86_64 -mmacosx-version-min=11.0" >"$WORK/macos.log" 2>&1 ||
        { tail -30 "$WORK/macos.log"; exit 1; }
    mkdir -p "$HERE/macos"
    cp "$WORK/macos/sjasmplus" "$HERE/macos/sjasmplus"
    strip "$HERE/macos/sjasmplus"
}

build_linux() {   # $1: x64 | arm64
    platform=linux/amd64
    [ "$1" = arm64 ] && platform=linux/arm64
    echo "== linux-$1 ($platform)"
    cp -R "$WORK/src" "$WORK/linux-$1"
    docker run --rm --platform "$platform" -v "$WORK/linux-$1:/src" -w /src alpine:3.20 sh -c \
        'apk add --no-cache build-base >/dev/null && make -j4 LDFLAGS="-static -s" >/build.log 2>&1 || { tail -30 /build.log; exit 1; }'
    mkdir -p "$HERE/linux-$1"
    cp "$WORK/linux-$1/sjasmplus" "$HERE/linux-$1/sjasmplus"
}

build_windows() {
    echo "== windows-x64 (MinGW-w64)"
    cp -R "$WORK/src" "$WORK/windows"
    docker run --rm --platform linux/amd64 -v "$WORK/windows:/src" -w /src debian:bookworm sh -c \
        'apt-get update -qq >/dev/null && apt-get install -y -qq make g++-mingw-w64-x86-64-posix gcc-mingw-w64-x86-64-posix binutils-mingw-w64-x86-64 >/dev/null &&
         make -f Makefile.win -j4 GCC=x86_64-w64-mingw32-gcc-posix GPP=x86_64-w64-mingw32-g++-posix WINDRES=x86_64-w64-mingw32-windres >/build.log 2>&1 ||
         { tail -30 /build.log; exit 1; }'
    mkdir -p "$HERE/windows-x64"
    cp "$WORK/windows/sjasmplus.exe" "$HERE/windows-x64/sjasmplus.exe"
}

case "$TARGET" in
    all) build_macos; build_linux x64; build_linux arm64; build_windows ;;
    macos) build_macos ;;
    linux-x64) build_linux x64 ;;
    linux-arm64) build_linux arm64 ;;
    windows-x64) build_windows ;;
    *) echo "unknown target $TARGET"; exit 2 ;;
esac
cp "$WORK/src/LICENSE.md" "$HERE/LICENSE.md"
echo "$TAG" >"$HERE/VERSION"
echo "done: $HERE"
