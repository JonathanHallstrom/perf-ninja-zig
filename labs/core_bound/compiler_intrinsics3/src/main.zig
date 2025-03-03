const std = @import("std");

const original = @import("original.zig");
const solution = @import("solution.zig");

const Position = @import("lib.zig").Position;

test {
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);

    const n = 128;
    var input: [n]Position = undefined;
    for (&input) |*e| e.* = .{ .x = rng.random().int(u32), .y = rng.random().int(u32), .z = rng.random().int(u32) };
    for (0..n + 1) |len| {
        const out_original = original.average(input[0..len]);
        const out_solution = original.average(input[0..len]);

        try std.testing.expectEqual(out_original, out_solution);
    }
}

comptime {
    @setEvalBranchQuota(1 << 30);
    const seed: u64 = 0;

    var rng = std.Random.DefaultPrng.init(seed);

    const n = 16;
    var input: [n]Position = undefined;
    for (&input) |*e| e.* = .{ .x = rng.random().int(u32), .y = rng.random().int(u32), .z = rng.random().int(u32) };
    for (0..n + 1) |len| {
        const out_original = original.average(input[0..len]);
        const out_solution = original.average(input[0..len]);

        std.testing.expectEqual(out_original, out_solution) catch unreachable;
    }
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

    const n = 64 << 8;
    const input: []Position = try allocator.alloc(Position, n);
    defer allocator.free(input);
    for (input) |*e| {
        e.* = .{
            .x = rng.random().int(u32),
            .y = rng.random().int(u32),
            .z = rng.random().int(u32),
        };
    }

    var timer = try std.time.Timer.start();
    if (!skip_original) {
        for (0..16 << 12) |_| {
            std.mem.doNotOptimizeAway(original.average(input));
        }
    }
    const old_time = timer.lap();
    if (!skip_solution) {
        for (0..16 << 12) |_| {
            std.mem.doNotOptimizeAway(solution.average(input));
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
                std.debug.print("new version is faster by: {d:.1}% (goal is >20% speedup)\n", .{percent});
            }
        } else {
            std.debug.print("new version is equivalent\n", .{});
        }
    }
}
