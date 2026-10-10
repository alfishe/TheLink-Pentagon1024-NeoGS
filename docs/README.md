# Documentation

| Document | What it is |
|---|---|
| [tutorial/](tutorial/README.md) | **How The Link works**, eleven chapters: the machine, the start, the frame handshake, one chapter per effect, the build. Start here to learn |
| [analysis.md](analysis.md) | the author's working disk taken apart: its files, how the demo assembles itself at every start, the page plan, the ZX / NeoGS protocol, what an emulator must provide, why the demo "hangs" on a classic General Sound |
| [loader.md](loader.md) | the release loader: what ALASM leaves in memory, the memory image at `GO` with every page, the machine check, the error screens, the music bug and its fix |
| [conversion.md](conversion.md) | from ALASM to sjasmplus: what the converter did, what was done by hand, the tables recomputed from the author's BASIC, how every byte was checked |
| [../history/](../materials/02-addons/README.md) | the intermediate builds and the first release, each still buildable |
| [images/](images/) | screenshots of every part and of the loader |

The quoted code is from the annotated sources in [`../src/`](../src/); each file starts with a
header that says what it builds, how its ZX half and its card half work together, and what the
conversion changed.
