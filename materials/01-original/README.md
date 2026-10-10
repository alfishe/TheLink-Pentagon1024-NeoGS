# materials/01-original — the author's originals

What the project started from, kept as found. The build reads only the disk image, and only for
the [intermediate builds](../02-addons/README.md); the sources it assembles are in [`src/`](../../src/README.md).

| Path | What |
|---|---|
| [`TheLink.trd`](TheLink.trd) | the author's **working disk**: the ALASM assembler (1024K build), the STS debugger, the 20 ALASM sources, the BASIC launcher and table programs, every binary and data file. `RUN "THELINK"` on it loads ALASM, which assembles the demo and runs it. It is not a release disk; the author never made one |
| [`alasm/`](alasm/) | the 20 sources (TR-DOS type `H`, ALASM's tokenized format) as UTF-8 text, comments converted from code page 866. The originals of [`src/`](../../src/) |
| [`basic/`](basic/) | the BASIC programs as listings: `THELINK.bas` (the launcher), `alasm64.bas` (ALASM's own), the table generators `sin+.bas`, `sectg.bas`, `sin32768.bas`, `uv256d.bas` ([`tools/tables.asm`](../../tools/tables.asm) repeats them) and `sin.bas`, whose table the demo does not use |

[`tools/extract_thelink.py`](../../tools/extract_thelink.py) regenerates `alasm/` and `basic/` from
the image. What is on the disk and how the demo starts there: [docs/analysis.md](../../docs/analysis.md).
