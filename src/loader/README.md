# src/loader — the release loader

The author's disk starts the demo through his assembler; [`loader.asm`](loader.asm) is the
ordinary start that replaces it. It runs at `#6000`, called from the `THELINK` BASIC program the
build writes:

1. checks the machine: Pentagon 1024 paging, and a NeoGS card (the detection of the NeoGS
   flasher); on anything else it shows what it found and returns to BASIC;
2. loads the title picture to the screen and draws a progress bar under it, then the main block
   (`thelink`) to `#7800` and the 28 page files to `#C000` of their pages, one segment of the
   bar per page file, zeroing the rest of each page as the assembler left it; a missing file
   turns the bar into a message naming it;
3. selects page 7 and jumps to `GO`.

The whole story — the memory image at `GO`, every page, the detection, the error screens, the
music bug the page 7 fixes — is in [docs/loader.md](../../docs/loader.md). The earlier versions are
in [materials/02-addons/](../../materials/02-addons/README.md).
