const std = @import("std");

const lib = @import("lib.zig");
const original = @import("original.zig");
const solution = @import("solution.zig");

test {
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);

    const input = lib.initRandomMatrix(&rng);
    const out_old = original.power(&input, 7);
    const out_new = solution.power(&input, 7);
    for (0..lib.N) |i| {
        for (0..lib.N) |j| {
            try std.testing.expect(std.math.isFinite(out_new[i][j]));
            try std.testing.expect(std.math.isFinite(out_old[i][j]));
            try std.testing.expect(std.math.approxEqAbs(f32, out_old[i][j], out_new[i][j], 0.001));
        }
    }
}

pub fn main() !void {
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);

    const input = lib.initRandomMatrix(&rng);
    const exponent = 2024;

    var timer = try std.time.Timer.start();
    for (0..1 << 2) |_| {
        std.mem.doNotOptimizeAway(original.power(&input, exponent));
    }
    const old_time = timer.lap();
    for (0..1 << 2) |_| {
        std.mem.doNotOptimizeAway(solution.power(&input, exponent));
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
            std.debug.print("new version is faster by: {d:.1}% (goal is >80% speedup)\n", .{percent});
        }
    } else {
        std.debug.print("new version is equivalent\n", .{});
    }
}
