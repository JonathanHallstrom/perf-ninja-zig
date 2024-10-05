const std = @import("std");

const lib = @import("lib.zig");
const N = lib.N;
const Matrix = lib.Matrix;
const identityMatrix = lib.identityMatrix;

// main focus is this
pub fn multiply(out: *Matrix, a: *const Matrix, b: *const Matrix) void {
    @setFloatMode(.optimized);
    for (out) |*row| @memset(row, 0);

    for (0..N) |i| {
        for (0..N) |k| {
            for (0..N) |j| {
                out[i][j] += a[i][k] * b[k][j];
            }
        }
    }
}

pub fn power(base: *const Matrix, exponent: usize) Matrix {
    // initialize to identity matrix
    var res_backing: [2]Matrix = .{identityMatrix} ** 2;
    var res_curr: *Matrix = &res_backing[0];
    var res_next: *Matrix = &res_backing[1];

    var prod_backing: [2]Matrix = .{base.*} ** 2;
    var prod_curr: *Matrix = &prod_backing[0];
    var prod_next: *Matrix = &prod_backing[1];

    var exp = exponent;
    while (exp > 0) : (exp >>= 1) {
        if (exp & 1 != 0) {
            multiply(res_next, res_curr, prod_curr);
            std.mem.swap(*Matrix, &res_next, &res_curr);
            if (exp == 1) break;
        }
        multiply(prod_next, prod_curr, prod_curr);
        std.mem.swap(*Matrix, &prod_next, &prod_curr);
    }
    return res_curr.*;
}
