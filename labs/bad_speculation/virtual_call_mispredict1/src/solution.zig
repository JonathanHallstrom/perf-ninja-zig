const std = @import("std");

const lib = @import("lib.zig");
const Dynamic = lib.Dynamic;

pub fn generate(arr: []Dynamic, rng: anytype) void {
    for (arr) |*e| {
        e.* = Dynamic.init(switch (rng.random().uintLessThan(u8, 3)) {
            0 => &lib.one,
            1 => &lib.two,
            else => &lib.three,
        });
    }
}

pub fn invoke(arr: []Dynamic, data: *usize) void {
    for (arr) |e| {
        e.handle(data);
    }
}
