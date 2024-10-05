const std = @import("std");

pub const N = 400;
pub const Matrix = [N][N]f32;
pub const identityMatrix = blk: {
    var res: Matrix = .{.{0} ** N} ** N;
    for (0..N) |i| {
        res[i][i] = 1;
    }
    break :blk res;
};

pub fn initRandomMatrix(rng: anytype) Matrix {
    var res: Matrix = undefined;

    for (0..N) |i| {
        var sum: f32 = 0;
        for (0..N) |j| {
            const r: f32 = @floatCast((rng.random().float(f64) - 0.5) * 1.9); // random float on [-0.95, 0.95]
            res[i][j] = r;
            sum += r * r;
        }
        if (sum > 0.01) {
            const scale = 1 / @sqrt(sum);
            for (0..N) |j| {
                res[i][j] *= scale;
            }
        }
    }
    return res;
}
