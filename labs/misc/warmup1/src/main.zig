const std = @import("std");

const original = @import("original.zig");
const solution = @import("solution.zig");

test {
    try std.testing.expectEqual(original.sum(100), solution.sum(100));
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

    var timer = try std.time.Timer.start();
    if (!skip_original) {
        for (0..1 << 12) |i| {
            std.mem.doNotOptimizeAway(original.sum(@intCast(i)));
        }
    }
    const old_time = timer.lap();
    if (!skip_solution) {
        for (0..1 << 12) |i| {
            std.mem.doNotOptimizeAway(solution.sum(@intCast(i)));
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
                std.debug.print("new version is faster by: {d:.1}% (goal is >90% speedup)\n", .{percent});
            }
        } else {
            std.debug.print("new version is equivalent\n", .{});
        }
    }
}
