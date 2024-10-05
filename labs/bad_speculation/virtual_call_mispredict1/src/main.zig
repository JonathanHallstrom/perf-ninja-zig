const std = @import("std");

const lib = @import("lib.zig");
const original = @import("original.zig");
const solution = @import("solution.zig");

test {
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(0);

    rng.seed(seed);
    var old_dynamic_dispatchers: [64]lib.Dynamic = undefined;
    original.generate(&old_dynamic_dispatchers, &rng);
    var old_data: usize = 0;
    original.invoke(&old_dynamic_dispatchers, &old_data);

    rng.seed(seed);
    var new_dynamic_dispatchers: [64]lib.Dynamic = undefined;
    solution.generate(&new_dynamic_dispatchers, &rng);
    var new_data: usize = 0;
    solution.invoke(&new_dynamic_dispatchers, &new_data);

    try std.testing.expectEqual(old_data, new_data);
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

    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);

    const n = 64 << 10;
    var old_dynamic_dispatchers: [n]lib.Dynamic = undefined;
    if (!skip_original) original.generate(&old_dynamic_dispatchers, rng.random());
    var new_dynamic_dispatchers: [n]lib.Dynamic = undefined;
    if (!skip_solution) solution.generate(&new_dynamic_dispatchers, rng.random());

    var data: usize = 0;
    var timer = try std.time.Timer.start();
    if (!skip_original) {
        for (0..16 << 10) |_| {
            std.mem.doNotOptimizeAway(original.invoke(&old_dynamic_dispatchers, &data));
        }
    }
    const old_time = timer.lap();
    if (!skip_solution) {
        for (0..16 << 10) |_| {
            std.mem.doNotOptimizeAway(solution.invoke(&new_dynamic_dispatchers, &data));
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
