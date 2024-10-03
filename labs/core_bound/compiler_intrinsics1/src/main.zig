const std = @import("std");

const original = @import("original.zig");
const solution = @import("solution.zig");

test {
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);

    const n = 64 << 10;
    var input: [n]u8 = undefined;
    var out_new: [n]u16 = undefined;
    var out_old: [n]u16 = undefined;
    for (&input) |*e| e.* = rng.random().uintAtMost(u8, 255);
    original.imageSmoothing(&input, 13, &out_old);
    solution.imageSmoothing(&input, 13, &out_new);

    try std.testing.expectEqualSlices(u16, &out_old, &out_new);
}

pub fn main() !void {
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);

    const n = 64 << 10;
    var input: [n]u8 = undefined;
    var output: [n]u16 = undefined;
    for (&input) |*e| e.* = rng.random().uintAtMost(u8, 255);

    var timer = try std.time.Timer.start();
    for (0..16 << 10) |_| {
        original.imageSmoothing(&input, 13, &output);
        std.mem.doNotOptimizeAway(output);
    }
    const old_time = timer.lap();
    for (0..16 << 10) |_| {
        solution.imageSmoothing(&input, 13, &output);
        std.mem.doNotOptimizeAway(output);
    }
    const new_time = timer.lap();
    const difference: i64 = @as(i64, @intCast(new_time)) - @as(i64, @intCast(old_time));

    const percent = @as(f64, @floatFromInt(@abs(difference))) * 100 / @as(f64, @floatFromInt(old_time));

    std.debug.print("old: {}\n", .{std.fmt.fmtDuration(old_time)});
    std.debug.print("new: {}\n", .{std.fmt.fmtDuration(new_time)});

    if (percent > 5) {
        if (difference > 0) {
            std.debug.print("new version is slower by: {d:.1}%\n", .{percent});
        } else {
            std.debug.print("new version is faster by: {d:.1}% (goal is >50% speedup)\n", .{percent});
        }
    } else {
        std.debug.print("new version is equivalent\n", .{});
    }
}
