const std = @import("std");

const original = @import("original.zig");
const solution = @import("solution.zig");

test {
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);

    const N = 1 << 20;

    var input: [N]u8 = undefined;
    var cur: u8 = rng.random().uintAtMost(u8, 255);
    for (0..N) |i| {
        if (rng.random().uintLessThan(u8, 64) == 0) cur = rng.random().uintAtMost(u8, 255);
        input[i] = cur;
    }

    try std.testing.expectEqual(original.histogram(&input), solution.histogram(&input));
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    var skip_original = false;
    var skip_solution = false;
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--skip-original")) skip_original = true;
        if (std.mem.eql(u8, arg, "--skip-solution")) skip_solution = true;
    }
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);

    const N = 1 << 20;
    var input: [N]u8 = undefined;
    var cur: u8 = rng.random().uintAtMost(u8, 255);
    for (0..N) |i| {
        if (rng.random().uintLessThan(u8, 64) == 0) cur = rng.random().uintAtMost(u8, 255);
        input[i] = cur;
    }

    var timer = try std.time.Timer.start();
    if (!skip_original) {
        for (0..1 << 10) |_| {
            std.mem.doNotOptimizeAway(original.histogram(&input));
        }
    }
    const old_time = timer.lap();
    if (!skip_solution) {
        for (0..1 << 10) |_| {
            std.mem.doNotOptimizeAway(solution.histogram(&input));
        }
    }
    const new_time = timer.lap();
    const difference: i64 = @as(i64, @intCast(new_time)) - @as(i64, @intCast(old_time));

    const percent = @as(f64, @floatFromInt(@abs(difference))) * 100 / @as(f64, @floatFromInt(old_time));

    if (!skip_original) std.debug.print("old: {}\n", .{std.fmt.fmtDuration(old_time)});

    if (!skip_solution) std.debug.print("new: {}\n", .{std.fmt.fmtDuration(new_time)});

    if (!skip_original and !skip_solution) {
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
}
