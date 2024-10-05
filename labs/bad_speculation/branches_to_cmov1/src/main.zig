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
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    var skip_original = false;
    var skip_solution = false;
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--skip-original")) skip_original = true;
        if (std.mem.eql(u8, arg, "--skip-solution")) skip_solution = true;
    }

    var original: [16]OriginalLife = undefined;
    for (&original) |*e| e.* = try OriginalLife.initRandom(allocator);
    defer for (&original) |*e| e.deinit();

    var new: [16]Life = undefined;
    for (&new) |*e| e.* = try Life.initRandom(allocator);
    defer for (&new) |*e| e.deinit();

    var timer = try std.time.Timer.start();

    if (!skip_original) {
        for (0..16) |_| {
            for (&original) |*e| {
                e.simulateNext();
                std.mem.doNotOptimizeAway(e.getPopulationCount());
            }
        }
    }
    const old_time = timer.lap();
    if (!skip_solution) {
        for (0..16) |_| {
            for (&new) |*e| {
                e.simulateNext();
                std.mem.doNotOptimizeAway(e.getPopulationCount());
            }
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
