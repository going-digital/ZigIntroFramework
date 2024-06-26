# Zig 4k intro framework

A pure Zig (+GLSL) framework for sizecoding intros, targetting PC, 32 bit.

## Project status
Visuals now working, but there is only a token audio synth.

## Build instructions

Use zig version 0.13.0.

* `zig build` to build debug version.
* `zig build --release=small` to build release version
* `zig build clean` to clean up.
* `zig build run` to run debug version.
* `zig build --release=small run` to run release version


## Credits

* Compression/Linker: [Crinkler](https://github.com/runestubbe/Crinkler)
* [Shader Minifier](https://github.com/laurentlb/shader-minifier)
* Framework inspiration: [Leviathan 2.0](https://github.com/armak/Leviathan-2.0)
* [Zigwin32](https://github.com/marlersoft/zigwin32)
