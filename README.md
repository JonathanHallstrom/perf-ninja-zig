# WARNING: SPOILERS AHEAD

# perf-ninja-zig
Zig port of [dendibakh/perf-ninja](https://github.com/dendibakh/perf-ninja/)

## Instructions
0. Read [dendibakh/perf-ninja](https://github.com/dendibakh/perf-ninja/)
1. Run `zig build test` to check your solution
2. Run `zig build run` to benchmark it
3. Optimize
4. Goto 1

## Profiling

To run only your code, pass the `--skip-original` flag (e.g., `zig build run -- --skip-original`), and to run only the original pass `--skip-solution`.
