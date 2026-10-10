# src/data — what the sources INCBIN

Files from the author's working disk ([`materials/01-original/TheLink.trd`](../../materials/01-original/TheLink.trd)),
unchanged: the bytes up to each file's catalog length. They are the demo's pictures, textures,
palettes, models and music — everything the sources take in with `INCBIN` that no source makes.
The four tables the author computed in BASIC are not here: [`tools/tables.asm`](../../tools/tables.asm)
computes them at every build.

Names are as the sources write them: a TR-DOS file of type `C` is `name`, another type is
`name.T` (`baba.0` is the file `baba` of type `0`); a few sources name the `C` type too
(`kishki.C`).

| File | Bytes | What | Used by |
|---|---|---|---|
| `medieval` | 6912 | the intro picture, shown while the card prepares the effects | `THELINK` |
| `credits` | 6912 | the credits screen, the last thing the demo shows | `THELINK` |
| `thelink$` | 6912 | the title picture: on screen while the release disk loads; the rotator's logo | the loader, `GSROTAT7` |
| `thelinkm` | 9810 | the music: a TurboSound FM player and its tune (init `#C000`, play `#C005`) | `THELINK` and every unit's test start |
| `torusr.p` | 10397 | the tunnel's lookup table (texture address per screen byte), Hrust-packed | `GSTUNNE4` |
| `dplan2r.p` | 3160 | the tunnel's plan of the screen, Hrust-packed | `GSTUNNE4` |
| `titletex` | 6912 | the rotator's texture (its first 4 KB, a ZX screen layout) | `GSROTAT7` |
| `gameover` | 6912 | the picture the rotating bars and the multi-bars cut into strips | `GSRBAR24`, `GSMULBA3` |
| `kishki.C` | 16384 | the hedgehog's texture | `hedge12`, `THELINK` |
| `palbrick` | 1024 | the hedgehog's palette: 4 colours per chunk value | `hedge12` |
| `DEMON16.C`, `DEMON17.C` | 16384 each | the dragon picture, 16 colours, two pages | `hedge12` |
| `baba.C`, `baba.0` | 16384, 8192 | the girl, 16 colours (the foreground layer) | `baba4`, `THELINK` |
| `mill.C`, `mill.0` | 16384, 13696 | the mill, 16 colours (the background layer) | `baba4`, `THELINK` |
| `girl13.2` | 16384 | the face's textures, 64 x 64 | `TEX28`, `THELINK` |
| `blugr.C`, `blugr.0`, `blugr.1`, `blugr.2` | 16384 each | the textured ball behind the face | `TEX28`, `THELINK` |
| `palgirl` | 1024 | the face's palette | `TEX28` |

`THELINK` places the large pictures and textures in the Spectrum's RAM pages; the demo then
uploads them to the card ([docs/loader.md](../../docs/loader.md) section 2).
