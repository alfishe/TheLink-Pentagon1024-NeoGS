# sjasmplus, vendored

The build uses [sjasmplus](https://github.com/z00m128/sjasmplus) **v1.23.1** with its built-in
Lua 5.5 (the tables, the disk images and the SHA-256 checks of `tools/` are Lua run by
sjasmplus). The binaries here let the project build with nothing else installed.

| Folder | Platform | Built |
|---|---|---|
| `macos/sjasmplus` | macOS 11 and later, universal (Apple silicon + Intel) | clang, `-arch arm64 -arch x86_64` |
| `linux-x64/sjasmplus` | any Linux on x86-64 | Alpine (musl), static |
| `linux-arm64/sjasmplus` | any Linux on ARM64 (Raspberry Pi 4/5 with a 64-bit OS, ARM servers) | Alpine (musl), static |
| `windows-x64/sjasmplus.exe` | Windows 10 and later, x64 | MinGW-w64, static |

`build.sh` picks the binary for the machine it runs on; `build.cmd` the Windows one;
`SJASMPLUS=/path/to/sjasmplus` overrides both (any sjasmplus 1.23 or later built with Lua).

All four were built from the upstream tag by [`build-sjasmplus.sh`](build-sjasmplus.sh) and
checked by building the demo with each: the same disk, byte for byte (Linux in Docker on both
architectures, Windows under Wine). To rebuild them:

```
tools/sjasmplus/build-sjasmplus.sh            # all; or macos, linux-x64, linux-arm64, windows-x64
```

| File | SHA-256 |
|---|---|
| `macos/sjasmplus` | `e7d3f9c25c7ae9116eea623ba1c811a736e2af02a46356b045dffeab067a38be` |
| `linux-x64/sjasmplus` | `0bf77918128f2c6cd3ae6668c238d73f43b7b0a1d62ee5287801da27a6691af1` |
| `linux-arm64/sjasmplus` | `cf0bfda2f29f826526d0dda404acc72699c1c925bf2b47d11bad2266b3f5e69a` |
| `windows-x64/sjasmplus.exe` | `cd667431219957e2db2f68c67f4a29683e58c95fa5f2777b046eb24ff82d171e` |

(A rebuild gives other hashes: compilers and linkers stamp their own bytes. The demo it builds
does not change.)

## License

sjasmplus is distributed under the BSD 3-clause license, [`LICENSE.md`](LICENSE.md). It contains
Lua (MIT license, © Lua.org, PUC-Rio), LuaBridge (MIT license) and crc32c (zlib license); their
notices are in the sjasmplus sources of the same tag.
