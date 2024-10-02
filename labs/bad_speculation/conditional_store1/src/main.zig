const std = @import("std");

const oldSelect = @import("original.zig").select;
const newSelect = @import("solution.zig").select;

test {
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);

    const n = 64 << 10;
    var input: [n][2]u32 = undefined;
    for (&input) |*e| e.* = .{
        rng.random().uintLessThan(u32, std.math.maxInt(u32)),
        rng.random().uintLessThan(u32, std.math.maxInt(u32)),
    };

    var out_old: [n][2]u32 = .{.{ 0, 0 }} ** n;
    var out_new: [n][2]u32 = .{.{ 0, 0 }} ** n;

    const old_len = oldSelect(n, &out_old, &input, 1 << 30, 1 << 31);
    const new_len = newSelect(n, &out_new, &input, 1 << 30, 1 << 31);

    try std.testing.expectEqualSlices([2]u32, out_old[0..old_len], out_new[0..new_len]);
}

pub fn main() !void {
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);

    const n = 64 << 10;
    var input: [n][2]u32 = undefined;
    for (&input) |*e| e.* = .{
        rng.random().uintLessThan(u32, std.math.maxInt(u32)),
        rng.random().uintLessThan(u32, std.math.maxInt(u32)),
    };

    var out: [n][2]u32 = .{.{ 0, 0 }} ** n;
    var timer = try std.time.Timer.start();
    for (0..16 << 10) |_| {
        const tmp = oldSelect(n, &out, &input, 1 << 30, 1 << 31);

        std.mem.doNotOptimizeAway(tmp);
        std.mem.doNotOptimizeAway(out);
    }
    const old_time = timer.lap();
    for (0..16 << 10) |_| {
        const tmp = newSelect(n, &out, &input, 1 << 30, 1 << 31);

        std.mem.doNotOptimizeAway(tmp);
        std.mem.doNotOptimizeAway(out);
    }
    const new_time = timer.lap();
    const difference: i64 = @as(i64, @intCast(new_time)) - @as(i64, @intCast(old_time));

    const percent = @as(f64, @floatFromInt(@abs(difference))) * 100 / @as(f64, @floatFromInt(old_time));

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
