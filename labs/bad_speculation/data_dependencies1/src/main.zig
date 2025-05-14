const std = @import("std");

// note: original implementation is from the standard library
// https://github.com/ziglang/zig/blob/985b13934da0eea9e01db6232c958485e30b97ef/lib/std/sort.zig#L675

const original = @import("original.zig");
const solution = @import("solution.zig");

test {
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);
    const n = 1 << 10;
    var arr: [n]u32 = undefined;
    for (&arr) |*e| e.* = rng.random().int(u32);

    std.mem.sort(u32, &arr, void{}, std.sort.asc(u32));

    for (0..n) |i| {
        try std.testing.expectEqual(original.binarySearch(&arr, arr[i]), solution.binarySearch(&arr, arr[i]));
        try std.testing.expectEqual(i, solution.binarySearch(&arr, arr[i]));
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    const allocator = arena.allocator();

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

    const n = 1 << 12;
    const input = try allocator.alloc(u32, n);
    for (input) |*e| e.* = rng.random().int(u32);

    const keys = try allocator.dupe(u32, input);
    rng.random().shuffle(u32, keys);

    for (input) |*e| @prefetch(e, .{});
    var timer = try std.time.Timer.start();
    if (!skip_original) {
        for (0..1 << 12) |_| {
            for (keys) |key| {
                std.mem.doNotOptimizeAway(original.binarySearch(input, key));
            }
        }
    }
    const old_time = timer.lap();
    if (!skip_solution) {
        for (0..1 << 12) |_| {
            for (keys) |key| {
                std.mem.doNotOptimizeAway(solution.binarySearch(input, key));
            }
        }
    }
    const new_time = timer.lap();
    const difference: i64 = @as(i64, @intCast(new_time)) - @as(i64, @intCast(old_time));
    const fraction = @as(f64, @floatFromInt(@abs(difference))) / @as(f64, @floatFromInt(old_time));
    const percent = (1 / (1 - fraction) - 1) * 100;

    if (!skip_original) std.debug.print("old: {}\n", .{std.fmt.fmtDuration(old_time)});

    if (!skip_solution) std.debug.print("new: {}\n", .{std.fmt.fmtDuration(new_time)});

    if (!skip_original and !skip_solution) {
        if (percent > 5) {
            if (difference > 0) {
                std.debug.print("new version is slower by: {d:.1}%\n", .{percent});
            } else {
                std.debug.print("new version is faster by: {d:.1}% (goal is >100% speedup)\n", .{percent});
            }
        } else {
            std.debug.print("new version is equivalent\n", .{});
        }
    }
}
