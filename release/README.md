# release — the two disks

| File | What it is |
|---|---|
| [`TheLink-NonDirectorsCut.scl`](TheLink-NonDirectorsCut.scl) | **The Link — Non-Director's Cut.** The demo as a finished release: built from source by this repository, it boots straight into the demo with no assembler in between, checks the machine first and says what is missing instead of hanging, and loads under a title picture. Everything the author's start leaves in memory is reproduced byte for byte, and the music is whole (the one bug of the first release build, [materials/02-addons/](../materials/02-addons/README.md), is fixed). 33 files, 1172 sectors, SHA-256 `53dd7ad7a007f74adcc60316c19d3632e506a1df54a93b0943c25334f9ee704d` |
| [`TheLink.trd`](TheLink.trd) | **The original, unfinished.** The author's working disk exactly as it was found (a copy of [materials/01-original/TheLink.trd](../materials/01-original/TheLink.trd)): no release was ever made. `RUN "THELINK"` loads the ALASM assembler and the STS debugger, assembles the demo from its sources and runs the result. It checks nothing: on a Pentagon 512 it stops during the assembly, with a classic General Sound it hangs at the first effect, and it never says why. On a Pentagon 1024 with a NeoGS it runs to the credits |

Both need a **Pentagon 1024** with a **NeoGS** card, and both show the same demo, frame for frame.

## The Non-Director's Cut

Insert `TheLink-NonDirectorsCut.scl`, `RUN` (or Enter in the TR-DOS menu):

| File on the disk | Type | Address | |
|---|---|---|---|
| `boot` | BASIC | | autostart: `RUN "THELINK"`, prints nothing |
| `THELINK` | BASIC | | `CLEAR 24575`, loads `loader`, starts it |
| `loader` | CODE | `#6000` | [src/loader/loader.asm](../src/loader/loader.asm): the machine check, then the rest |
| `thelink$` | CODE | `#4000` | the title picture, on screen while the rest loads |
| `thelink` | CODE | `#7800` | the main block, [src/THELINK.asm](../src/THELINK.asm) |
| 28 more | CODE | `#C000` | the page files: effect objects, pictures, textures, music ([docs/loader.md](../docs/loader.md) section 2) |

`./build.sh` / `build.cmd` make it again as `build/TheLink-NonDirectorsCut.scl`, byte for byte this file.

## The original

Insert `TheLink.trd`, `RUN "THELINK"`. What is on it and how its start works:
[docs/analysis.md](../docs/analysis.md).
