#!/bin/sh
# The Link - build from source with the vendored sjasmplus (macOS, Linux).
#
#   ./build.sh              the demo: build/TheLink-NonDirectorsCut.scl
#   ./build.sh experiment   the same from changed sources: differences from the author's files are reported
#   ./build.sh stage1       an earlier stage (materials/02-addons/README.md): stage1, stage2
#   ./build.sh clean        remove build/
#
# SJASMPLUS=/path/to/sjasmplus uses another sjasmplus (1.23 or later, built with Lua).
# Everything is built in build/obj (listings *.lst there too); a sjasmplus error or warning stops the build.
# VERBOSE=1 also shows what the sources DISPLAY while they assemble (sizes and addresses the author printed).
set -eu

ROOT=$(cd "$(dirname "$0")" && pwd)
case "$(uname -s)-$(uname -m)" in
    Darwin-*) VENDORED=$ROOT/tools/sjasmplus/macos/sjasmplus ;;
    Linux-x86_64 | Linux-amd64) VENDORED=$ROOT/tools/sjasmplus/linux-x64/sjasmplus ;;
    Linux-aarch64 | Linux-arm64) VENDORED=$ROOT/tools/sjasmplus/linux-arm64/sjasmplus ;;
    *) VENDORED= ;;
esac
SJ=${SJASMPLUS:-$VENDORED}
if [ -z "$SJ" ] || [ ! -x "$SJ" ]; then
    echo "no sjasmplus for $(uname -s) $(uname -m): set SJASMPLUS=/path/to/sjasmplus" >&2
    exit 1
fi

TARGET=${1:-demo}
OUT=$ROOT/build
BUILD=$OUT/obj
if [ "$TARGET" = clean ]; then
    rm -rf "$OUT"
    exit 0
fi

# One assembly: the source, then sjasmplus' options. Its messages are shown; a warning fails like an error.
asm() {
    source=$1
    shift
    name=$(basename "$source" .asm)
    printf '  %-52s ' "$(echo "$source" | sed "s|^$ROOT/||")"
    status=0
    log=$("$SJ" --nologo --msg=war --lst="$name.lst" "$@" "$source" 2>&1) || status=$?
    printf '%s\n' "$log" >"$name.log"
    if [ "$status" -ne 0 ]; then
        echo "failed"
        echo "$log"
        exit 1
    fi
    if echo "$log" | grep -qi "warning"; then
        echo "warnings"
        echo "$log"
        exit 1
    fi
    echo "ok"
    # The sources' own DISPLAY lines ("> ...") with VERBOSE=1; the build's messages always
    if [ -n "${VERBOSE:-}" ]; then shown=$log; else shown=$(echo "$log" | grep -v '^> ' || true); fi
    [ -z "$shown" ] || echo "$shown" | sed 's/^/    /'
}

rm -rf "$OUT"
mkdir -p "$BUILD"
cd "$BUILD"
echo "The Link: $TARGET, $("$SJ" --version 2>&1 | head -1)"
case "$TARGET" in
    demo | experiment)
        asm "$ROOT/tools/tables.asm"
        for unit in GSTUNNE4 GSROTAT7 GSRBAR24 GSMULBA3 hedge12 baba4 TEX28 THELINK; do
            asm "$ROOT/src/$unit.asm" "-I$ROOT/src" "-I$ROOT/src/data" "-I."
        done
        asm "$ROOT/src/loader/loader.asm"
        if [ "$TARGET" = experiment ]; then asm "$ROOT/tools/release.asm" -DEXPERIMENT=1; else asm "$ROOT/tools/release.asm"; fi
        ;;
    stage1 | stage2)
        n=${TARGET#stage}
        dir=$(ls -d "$ROOT/materials/02-addons/stage$n"-*)
        asm "$dir/thelink_main.asm" "-I$ROOT/src/data"
        asm "$dir/loader.asm"
        asm "$ROOT/tools/release.asm" "-DSTAGE=$n"
        ;;
    *)
        echo "unknown target $TARGET (demo, experiment, stage1, stage2, clean)" >&2
        exit 2
        ;;
esac
echo "done: $(cd "$OUT" && ls *.scl) in build/, boot it on a Pentagon 1024 with a NeoGS"
