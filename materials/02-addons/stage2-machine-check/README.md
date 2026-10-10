# materials/02-addons/stage2-machine-check — the loader that checks the machine

Stage 1 plus a machine check: before loading anything the loader makes sure it runs on a
Pentagon 1024 (1024K paging) with a NeoGS card, and on anything else shows what it found
(512K or 128K memory, a classic General Sound, no card) instead of starting a demo that would
hang. The current build uses this loader with a progress bar added ([`src/loader/`](../../../src/loader/README.md)).

| File | What |
|---|---|
| [`loader.asm`](loader.asm) | the loader at `#6000`: machine check, error screen, loading, `JP GO` |
| [`thelink_main.asm`](thelink_main.asm) | the hand port of the block at `#7800`, as in stage 1 |

`./build.sh stage2` (`build.cmd stage2`) builds the disk; the effects and data come from
[`materials/01-original/TheLink.trd`](../../01-original/TheLink.trd). It puts in memory exactly what the current
build puts there from source; the current loader adds the progress bar. How the check works: [docs/loader.md](../../../docs/loader.md)
section 4. More: [materials/02-addons/README.md](../README.md).
