const std = @import("std");

const Position = @import("lib.zig").Position;

pub fn average(input: []Position) Position {
    var x: u64 = 0;
    var y: u64 = 0;
    var z: u64 = 0;
    for (input) |pos| {
        x += pos.x;
        y += pos.y;
        z += pos.z;
    }

    return .{
        .x = @intCast(x / @max(input.len, 1)),
        .y = @intCast(y / @max(input.len, 1)),
        .z = @intCast(z / @max(input.len, 1)),
    };
}
