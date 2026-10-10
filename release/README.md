# release — the two disks

| File | What it is |
|---|---|
| [`TheLink-NonDirectorsCut.scl`](TheLink-NonDirectorsCut.scl) | **The Link — Non-Director's Cut.** The demo as a finished release: built from source by this repository, it boots straight into the demo with no assembler in between, checks the machine first and says what is missing instead of hanging, and loads under the title picture with a progress bar, one segment per RAM page (a missing file turns the bar into a message naming it). Everything the author's start leaves in memory is reproduced byte for byte, and the music is whole (the one bug of the first release build, [materials/02-addons/](../materials/02-addons/README.md), is fixed). 33 files, 1173 sectors, SHA-256 `5102376be31748368993c275bcd9dcd834e5ed131feee115ecd3bc46a9d0af22` |
| [`TheLink.trd`](TheLink.trd) | **The original, unfinished.** The author's working disk exactly as it was found (a copy of [materials/01-original/TheLink.trd](../materials/01-original/TheLink.trd)): no release was ever made. `RUN "THELINK"` loads the ALASM assembler and the STS debugger, assembles the demo from its sources and runs the result. It checks nothing: on a Pentagon 512 it stops during the assembly, with a classic General Sound it hangs at the first effect, and it never says why. On a Pentagon 1024 with a NeoGS it runs to the credits |

Important Note: **Pentagon 1024** with a **NeoGS** card, and both releases show the same demo, frame for frame.

## The Non-Director's Cut

Insert `TheLink-NonDirectorsCut.scl`, `RUN` (or Enter in the TR-DOS menu):

| File on the disk | Type | Address | |
|---|---|---|---|
| `boot` | BASIC | | autostart: `RUN "THELINK"`, prints nothing |
| `THELINK` | BASIC | | `CLEAR 24575`, loads `loader`, starts it |
| `loader` | CODE | `#6000` | [src/loader/loader.asm](../src/loader/loader.asm): the machine check, then the rest under a progress bar |
| `thelink$` | CODE | `#4000` | the title picture, on screen while the rest loads |
| `thelink` | CODE | `#7800` | the main block, [src/THELINK.asm](../src/THELINK.asm) |
| 28 more | CODE | `#C000` | the page files: effect objects, pictures, textures, music ([docs/loader.md](../docs/loader.md) section 2) |

`./build.sh` / `build.cmd` make it again as `build/TheLink-NonDirectorsCut.scl`, byte for byte this file.

## The original

Insert `TheLink.trd`, `RUN "THELINK"`. What is on it and how its start works:
[docs/analysis.md](../docs/analysis.md).
