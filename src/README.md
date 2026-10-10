# src — the sources the demo is built from

Everything here goes into the build (`./build.sh` / `build.cmd` at the top). The 20 `.asm` files
are the author's ALASM sources converted to [sjasmplus](../tools/sjasmplus/README.md) and
annotated: each starts with an English header (what it builds, how its Spectrum half and its
NeoGS half work together, what the conversion added), and English notes stand next to the
author's Russian comments, which are kept as he wrote them. The code itself is the author's,
byte for byte: the build checks every object against his files.

| Folder | What |
|---|---|
| [`data/`](data/README.md) | pictures, textures, palettes, 3D models and the music the sources `INCBIN`, from the author's disk |
| [`loader/`](loader/README.md) | the release loader: machine check, then the files to their pages, then `GO` |

## The effect units

Each unit is assembled on its own and writes its objects with `SAVEBIN`: a `*ZX` object runs on
the Spectrum, a `*GS` object on the card (`*PREGS`: card code that precomputes tables first).

| Source | Also includes | Builds | Part | Chapter |
|---|---|---|---|---|
| [`GSTUNNE4.asm`](GSTUNNE4.asm) | `gsports`, `SAVEOBJ4` | `TUNNELZX`, `TUNNELGS` | tunnel | [4](../docs/tutorial/04-tunnel.md) |
| [`GSROTAT7.asm`](GSROTAT7.asm) | `gsports`, `SAVEOBJ4` | `ROTATEZX`, `ROTPREGS`, `ROTATEGS` | rotator (the logo) | [5](../docs/tutorial/05-rotator.md) |
| [`GSRBAR24.asm`](GSRBAR24.asm) | + [`GSRBARP3.asm`](GSRBARP3.asm) (the bar rasteriser) | `ROTBARZX`, `ROBPREGS`, `ROTBARGS` | rotating bars | [6](../docs/tutorial/06-rotating-bars.md) |
| [`GSMULBA3.asm`](GSMULBA3.asm) | `gsports`, `SAVEOBJ4` | `MULBARZX`, `MULBARGS` | multi-bars | [7](../docs/tutorial/07-multi-bars.md) |
| [`hedge12.asm`](hedge12.asm) | + [`texpp4`](texpp4.asm), [`vujump`](vujump.asm), [`instlpp`](instlpp.asm) | `HEDGEZX1`, `HEDGEZX2`, `HEDGEGS` | hedgehog (the dragon) | [8](../docs/tutorial/08-hedgehog.md) |
| [`baba4.asm`](baba4.asm) | `gsports`, `SAVEOBJ4` | `BABAZX`, `BABAGS` | girl and mill | [9](../docs/tutorial/09-girl-and-mill.md) |
| [`TEX28.asm`](TEX28.asm) | + [`texpp4`](texpp4.asm), [`vujump`](vujump.asm), [`instpp3`](instpp3.asm) | `TEXZX`, `TEXGS` | textured face | [10](../docs/tutorial/10-textured-face.md) |

[`THELINK.asm`](THELINK.asm) is the main module ([chapter 2](../docs/tutorial/02-the-start.md)):
it assembles the block at `#7800` — `GO`, the card program, the Spectrum's resident loop, the
interrupt handler, the credits, the intro picture — and lays out every object and data file in
its RAM page. Only the `#7800` block is saved (`thelink`); the loader loads the page files itself.

Shared by all: [`gsports.asm`](gsports.asm) (the NeoGS port names and the mailbox macros) and
[`SAVEOBJ4.asm`](SAVEOBJ4.asm) (the author's object saver for ALASM; still assembled, its table
is what the `SAVEBIN` lines at the end of each unit write).

## Kept as the author left them, not built

| Source | |
|---|---|
| [`baba5.asm`](baba5.asm) | a later take on `baba4` (a zoom of the background); its `BABAGS` is not the one on the disk |
| [`hedgepre.asm`](hedgepre.asm) | a sibling of `hedge12`; it reads `demon16.p`, a file not on the disk |
| [`RECPIC.asm`](RECPIC.asm) | recodes a picture to the 16-colour format; its input files are not on the disk |
| [`16CCON.asm`](16CCON.asm) | converts a 16-colour BMP on the Spectrum |
| [`m2hrust.asm`](m2hrust.asm) | the author's Hrust packer and release maker; `THELINK.asm` includes it, the demo never calls it |

## Assembling one unit by hand

After a build, in `build/obj` (where the tables are):

```
../../tools/sjasmplus/macos/sjasmplus -I../../src -I../../src/data ../../src/GSTUNNE4.asm
```

(`linux-x64`, `linux-arm64` or `windows-x64\sjasmplus.exe` on other systems.) How the sources
were converted: [docs/conversion.md](../docs/conversion.md).
