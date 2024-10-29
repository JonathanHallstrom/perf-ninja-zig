const std = @import("std");

const lib = @import("lib.zig");
const N = lib.N;
const Matrix = lib.Matrix;

// main focus is this
pub fn transpose(out: *Matrix, in: *const Matrix) void {
    const incr = 64;
    var lo_i: usize = 0;
    var hi_i: usize = 0;
    while (lo_i < N) : ({
        lo_i = hi_i;
        hi_i = @min(hi_i + incr, N);
    }) {
        var lo_j: usize = 0;
        var hi_j: usize = 0;
        while (lo_j < N) : ({
            lo_j = hi_j;
            hi_j = @min(hi_j + incr, N);
        }) {
            for (lo_i..hi_i) |i| {
                for (lo_j..hi_j) |j| {
                    out[i][j] = in[j][i];
                }
            }
        }
    }
}