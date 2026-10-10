# materials/02-addons — the intermediate builds

The road from the author's working disk to a demo built from source went through two
intermediate builds. They are kept here for the record: each still builds and boots, and each
shows one step of the work ([docs/tutorial/11-building-it.md](../../docs/tutorial/11-building-it.md)
tells the story). Nothing here is needed to build the demo itself, which comes from
[`src/`](../../src/README.md).

```
./build.sh stage1          build.cmd stage1          -> build/TheLink-stage1.scl
./build.sh stage2          build.cmd stage2          -> build/TheLink-stage2.scl
```

| Stage | Where | What it adds | Takes from the author's disk | Disk (SHA-256 checked by the build) |
|---|---|---|---|---|
| 0. The original | [`materials/`](../01-original/README.md) | the author's start: `RUN "THELINK"` loads ALASM, which assembles the demo and runs it | everything | `materials/01-original/TheLink.trd` |
| 1. A loader | [`stage1-loader/`](stage1-loader/README.md) | a loader instead of the assembler: title, main block, 28 page files by TR-DOS, `JP #7800`. No machine check: on a wrong machine it starts the demo anyway | the effect binaries, pictures, music | 1169 sectors, `ff5a446e...` |
| 2. The machine check | [`stage2-machine-check/`](stage2-machine-check/README.md) | Pentagon 1024 paging and NeoGS detection before loading; an error screen naming what is missing | the same | 1172 sectors, `53dd7ad7...` |
| 3. From source | [`src/`](../../src/README.md), the current build | every effect converted from ALASM to sjasmplus and assembled; the tables computed; the stage 2 loader | pictures, models, music only | `release/TheLink-NonDirectorsCut.scl`, `53dd7ad7...` |

Stages 1 and 2 assemble the main block from `thelink_main.asm`, the code part of `THELINK.asm`
ported to sjasmplus by hand (it is what showed that ALASM's `JNZ` is `JR NZ`: the first port was
6 bytes longer). Stage 3 replaced it with the converted `src/THELINK.asm`, which builds the same
14677 bytes. For stages 1 and 2 `tools/release.asm` takes the page files straight from
`materials/01-original/TheLink.trd`, as the author's start did.

Stage 2 and stage 3 build the same disk byte for byte: the same loader, and the objects stage 3
assembles are the author's binaries stage 2 copies.

## The music fix, and the first release build

`GO` clears `#D800`-`#DAFF` of whatever page is at `#C000`; the first loader left the music page
there and 733 bytes of the player were zeroed (the picture was unaffected, so a screen compare
missed it; [docs/loader.md](../../docs/loader.md) section 4). The fix - `#7FFD` = `#17` before
`JP GO` - is in the loaders of all three stages, so every disk here plays the music whole.

[`TheLink-first-release.scl`](TheLink-first-release.scl) is the first release build, kept as it
was: stage 2 **without** the fix. It boots into the demo; its music page differs from `thelinkm`
in those 733 bytes.

| Disk | SHA-256 |
|---|---|
| `TheLink-first-release.scl` (no fix) | `559312bf2a36b329416ca415079709b24fe68ae41a0b3d618002ea4728c8a749` |
| stage 1 | `ff5a446eef0fba2300d136e89721f766733229c4042f8619caf6417483851ada` |
| stage 2 = stage 3 = `release/TheLink-NonDirectorsCut.scl` | `53dd7ad7a007f74adcc60316c19d3632e506a1df54a93b0943c25334f9ee704d` |
