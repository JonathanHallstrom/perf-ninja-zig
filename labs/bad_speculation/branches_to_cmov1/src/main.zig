const std = @import("std");

const x_dim = 1024;
const y_dim = 1024;
const OriginalLife = @import("original.zig").Life(x_dim, y_dim);
const Life = @import("solution.zig").Life(x_dim, y_dim);

test {
    const seed: u64 = @intCast(std.time.microTimestamp());

    var new_life: Life = try Life.initRandomWithSeed(std.testing.allocator, seed);
    defer new_life.deinit();

    var old_life: OriginalLife = try OriginalLife.initRandomWithSeed(std.testing.allocator, seed);
    defer old_life.deinit();

    try std.testing.expectEqual(old_life.getPopulationCount(), new_life.getPopulationCount());
    for (0..16) |_| {
        new_life.simulateNext();
        old_life.simulateNext();
        try std.testing.expectEqual(old_life.getPopulationCount(), new_life.getPopulationCount());
    }
}

pub fn main() !void {
    const allocator = std.heap.raw_c_allocator;

    var original: [16]OriginalLife = undefined;
    for (&original) |*e| e.* = try OriginalLife.initRandom(allocator);
    defer for (&original) |*e| e.deinit();

    var new: [16]Life = undefined;
    for (&new) |*e| e.* = try Life.initRandom(allocator);
    defer for (&new) |*e| e.deinit();

    var timer = try std.time.Timer.start();
    for (0..16) |_| {
        for (&original) |*e| {
            e.simulateNext();
            std.mem.doNotOptimizeAway(e.getPopulationCount());
        }
    }
    const old_time = timer.lap();
    for (0..16) |_| {
        for (&new) |*e| {
            e.simulateNext();
            std.mem.doNotOptimizeAway(e.getPopulationCount());
        }
    }
    const new_time = timer.lap();
    const difference: i64 = @as(i64, @intCast(new_time)) - @as(i64, @intCast(old_time));

    const percent = @as(f64, @floatFromInt(@abs(difference))) * 100 / @as(f64, @floatFromInt(old_time));

    if (percent > 5) {
        if (difference > 0) {
            std.debug.print("new version is slower by: {d:.1}%\n", .{percent});
        } else {
            std.debug.print("new version is faster by: {d:.1}% (goal is ~20% speedup)\n", .{percent});
        }
    } else {
        std.debug.print("new version is equivalent\n", .{});
    }
}
