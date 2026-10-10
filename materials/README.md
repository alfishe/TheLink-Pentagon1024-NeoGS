# materials — what the project started from and went through

Nothing here is needed to build the demo: that comes from [`src/`](../src/README.md). These are
the sources of the sources, and the steps on the way.

| Folder | What |
|---|---|
| [`01-original/`](01-original/README.md) | the author's working disk `TheLink.trd` as it was found, and what was extracted from it: the 20 ALASM sources and the BASIC programs as text |
| [`02-addons/`](02-addons/README.md) | what was made on the way to building from source: stage 1 (a loader instead of the assembler), stage 2 (the loader with the machine check), and the first release disk, kept with its music bug. Both stages still build: `./build.sh stage1`, `./build.sh stage2` |

The way from the one to the other: [docs/tutorial/11-building-it.md](../docs/tutorial/11-building-it.md).
