const std = @import("std");

const lib = @import("lib.zig");
const Dynamic = lib.Dynamic;

pub fn generate(arr: []Dynamic, rng: std.Random) void {
    var counts: [3]usize = .{0} ** 3;
    for (arr) |_| {
        counts[rng.uintLessThan(u8, 3)] += 1;
    }
    for (arr) |*e| {
        inline for (&counts, 0..) |*c, i| {
            if (c.* > 0) {
                e.* = Dynamic.init(i);
                c.* -= 1;
                break;
            }
        }
    }
}

pub fn invoke(arr: []Dynamic, data: *usize) void {
    for (arr) |e| {
        e.handle(data);
    }
}
