const std = @import("std");

const lib = @import("lib.zig");
const N = lib.N;
const Matrix = lib.Matrix;
const identityMatrix = lib.identityMatrix;

// main focus is this
pub fn transpose(out: *Matrix, in: *const Matrix) void {
    for (0..N) |i| {
        for (0..N) |j| {
            out[i][j] = in[j][i];
        }
    }
}
