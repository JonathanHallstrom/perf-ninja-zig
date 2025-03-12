# perf-ninja-zig
Zig port of [dendibakh/perf-ninja](https://github.com/dendibakh/perf-ninja/)

## Instructions
10 Read [dendibakh/perf-ninja](https://github.com/dendibakh/perf-ninja/) \
20 Choose an exercise and go to its directory (for example `labs/misc/warmup1`) \
30 Run `zig build test` to check your solution \
40 Run `zig build run` to benchmark it* \
50 Optimize \
60 GOTO 20
   
*If you are using an IDE and you press a `run` button or similar it likely won't apply the proper optimization mode

## Profiling

To run only your code, pass the `--skip-original` flag (e.g., `zig build run -- --skip-original`), and to run only the original pass `--skip-solution`.
