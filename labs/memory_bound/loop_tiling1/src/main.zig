const std = @import("std");

const lib = @import("lib.zig");
const original = @import("original.zig");
const solution = @import("solution.zig");

test {
    const seed: u64 = @intCast(std.time.microTimestamp());
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var rng = std.Random.DefaultPrng.init(seed);

    const input = try lib.initRandomMatrix(allocator, rng.random());

    const out_old = try allocator.create(lib.Matrix);
    original.transpose(out_old, input);
    const out_new = try allocator.create(lib.Matrix);
    solution.transpose(out_new, input);

    for (0..lib.N) |i| {
        for (0..lib.N) |j| {
            try std.testing.expect(std.math.isFinite(out_new[i][j]));
            try std.testing.expect(std.math.isFinite(out_old[i][j]));
            try std.testing.expect(std.math.approxEqAbs(f32, out_old[i][j], out_new[i][j], 0.001));
        }
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

    const input = try lib.initRandomMatrix(allocator, rng.random());
    const output = try allocator.create(lib.Matrix);

    var timer = try std.time.Timer.start();
    if (!skip_original) {
        for (0..1 << 4) |_| {
            std.mem.doNotOptimizeAway(original.transpose(output, input));
            std.mem.doNotOptimizeAway(input);
            std.mem.doNotOptimizeAway(output);
        }
    }
    const old_time = timer.lap();
    if (!skip_solution) {
        for (0..1 << 4) |_| {
            std.mem.doNotOptimizeAway(solution.transpose(output, input));
            std.mem.doNotOptimizeAway(input);
            std.mem.doNotOptimizeAway(output);
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
