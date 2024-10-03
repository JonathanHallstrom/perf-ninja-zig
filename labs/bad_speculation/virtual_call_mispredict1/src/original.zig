const std = @import("std");

const lib = @import("lib.zig");
const Dynamic = lib.Dynamic;

pub fn generate(arr: []Dynamic, rng: std.Random) void {
    for (arr) |*e| {
        e.* = Dynamic.init(rng.uintLessThan(u8, 3));
    }
}

pub fn invoke(arr: []Dynamic, data: *usize) void {
    for (arr) |e| {
        e.handle(data);
    }
}
