# Licenses

This repository holds three kinds of work.

## 1. The demo

**The Link** (invdemo, 2009): code and music by Alone Coder; graphics by Alone Coder, Oimidrol
and Shiru. The author's working disk (`materials/01-original/TheLink.trd`), the sources extracted from it
(`materials/01-original/alasm/`, `materials/01-original/basic/`), the data files (`src/data/`) and the code of the converted
sources (`src/`) are their work. The demo was released free in the ZX Spectrum scene; it is kept
here for study and preservation, and all rights to it remain with its authors.

## 2. This project

Everything made for this repository - the build scripts (`build.sh`, `build.cmd`), the build
tools (`tools/`, except `tools/sjasmplus/`), the release loader (`src/loader/`, `materials/02-addons/*/loader.asm`),
the hand port `materials/02-addons/*/thelink_main.asm` as far as it differs from the original, the English
annotations in `src/`, the documentation (`docs/`, the README files) and the screenshots - is
under the MIT license:

```
MIT License

Copyright (c) 2026 the TheLink-NeoGS contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

## 3. sjasmplus

The vendored assembler in `tools/sjasmplus/` is sjasmplus v1.23.1, BSD 3-clause license
([`tools/sjasmplus/LICENSE.md`](tools/sjasmplus/LICENSE.md)), with Lua, LuaBridge and crc32c
inside ([`tools/sjasmplus/README.md`](tools/sjasmplus/README.md)).
