const std = @import("std");

const original = @import("original.zig");
const solution = @import("solution.zig");

test {
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);

    const n = 64 << 10;
    var input: [n]u8 = undefined;
    for (0..32) |_| {
        for (&input) |*e| e.* = switch (rng.random().uintAtMost(u8, 26)) {
            0...25 => |o| o + 'a',
            else => '\n',
        };
        try std.testing.expectEqual(original.longestLine(&input), solution.longestLine(&input));
    }
}

pub fn main() !void {
    comptime var inputs: []const []const u8 = &.{};
    inline for (.{
        "udivmodti4_test.zig",
        "MarkTwain-TomSawyer.txt",
        // "counter-example.txt",
    }) |filename| {
        inputs = inputs ++ @as([]const []const u8, &.{@embedFile("./inputs/" ++ filename)});
    }

    var timer = try std.time.Timer.start();
    const char_amt = 16 << 20;
    for (0..1 << 5) |_| {
        for (inputs) |input| {
            // do approximately the same amount of work for each input
            for (0..(char_amt + input.len - 1) / input.len) |_|
                std.mem.doNotOptimizeAway(original.longestLine(input));
        }
    }
    const old_time = timer.lap();
    for (0..1 << 5) |_| {
        for (inputs) |input| {
            // do approximately the same amount of work for each input
            for (0..(char_amt + input.len - 1) / input.len) |_|
                std.mem.doNotOptimizeAway(solution.longestLine(input));
        }
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
