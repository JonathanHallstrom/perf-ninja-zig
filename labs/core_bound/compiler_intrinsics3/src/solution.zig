const std = @import("std");

const Position = @import("lib.zig").Position;

pub fn average(input: []Position) Position {
    var i: usize = 0;

    const vec_size = std.simd.suggestVectorLength(u32) orelse 4;

    var accs: [3]@Vector(vec_size, u64) = .{@as(@Vector(vec_size, u64), @splat(0))} ** 3;
    while (i + vec_size <= input.len) : (i += vec_size) {
        comptime std.debug.assert(@sizeOf([3]@Vector(vec_size, u32)) == @sizeOf([vec_size]Position));

        const vals: [3]@Vector(vec_size, u32) = @bitCast(input[i..][0..vec_size].*);
        for (0..3) |j| {
            accs[j] += vals[j];
        }
    }

    var x: u64 = 0;
    var y: u64 = 0;
    var z: u64 = 0;

    const accumulator: [*]u64 = @ptrCast(&accs);
    for (0..vec_size) |j| {
        x += accumulator[j * 3];
        y += accumulator[j * 3 + 1];
        z += accumulator[j * 3 + 2];
    }

    while (i < input.len) : (i += 1) {
        x += input[i].x;
        y += input[i].y;
        z += input[i].z;
        std.mem.doNotOptimizeAway(i);
    }

    return .{
        .x = @intCast(x / @max(input.len, 1)),
        .y = @intCast(y / @max(input.len, 1)),
        .z = @intCast(z / @max(input.len, 1)),
    };
}
