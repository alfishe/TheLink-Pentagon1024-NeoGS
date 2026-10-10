# materials/02-addons/stage1-loader — the first loader

The first replacement for the author's start: instead of loading ALASM and assembling the demo,
a loader puts the title on screen, loads the main block to `#7800` and the 28 page files to their
pages by TR-DOS, and jumps to `GO`. It does not check the machine yet.

| File | What |
|---|---|
| [`loader.asm`](loader.asm) | the loader at `#6000` (with the music fix, [materials/02-addons/README.md](../README.md)) |
| [`thelink_main.asm`](thelink_main.asm) | the code part of the author's `THELINK.asm` ported to sjasmplus by hand: the block at `#7800`, byte for byte what ALASM builds |

`./build.sh stage1` (`build.cmd stage1`) assembles both and writes the disk; the effects, the
pictures and the music come as they are from [`materials/01-original/TheLink.trd`](../../01-original/TheLink.trd).
More: [materials/02-addons/README.md](../README.md).
