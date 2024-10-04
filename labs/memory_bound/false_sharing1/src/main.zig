const std = @import("std");

const original = @import("original.zig");
const solution = @import("solution.zig");

test {
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);

    const n = 64 << 10;
    var input: [n]u32 = undefined;
    for (&input) |*e| e.* = rng.random().uintAtMost(u32, n);

    const cpu_count = std.Thread.getCpuCount() catch 1;

    try std.testing.expectEqual(
        original.solution(&input, cpu_count, std.testing.allocator),
        solution.solution(&input, cpu_count, std.testing.allocator),
    );
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);
    const cpu_count = std.Thread.getCpuCount() catch 1;

    const n = 1 << 20;
    var input: [n]u32 = undefined;
    for (&input) |*e| e.* = rng.random().uintAtMost(u32, n);

    var timer = try std.time.Timer.start();
    for (0..1 << 5) |_| {
        std.mem.doNotOptimizeAway(original.solution(&input, cpu_count, allocator));
    }
    const old_time = timer.lap();
    for (0..1 << 5) |_| {
        std.mem.doNotOptimizeAway(solution.solution(&input, cpu_count, allocator));
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
