const std = @import("std");

const original = @import("original.zig");
const solution = @import("solution.zig");

fn generateFile(name: []const u8, size: usize, rng: anytype) !void {
    if (std.fs.cwd().openFile(name, .{})) |f| {
        if (f.stat()) |stats| {
            const actual_size: isize = @intCast(stats.size);
            const desired_size: isize = @intCast(size);
            // if size is off by less than 1% thats fine
            if (100 * @abs(actual_size - desired_size) / size < 1) {
                std.debug.print("{s} already exists, skipping\n", .{name});
                return;
            }
        } else |_| {}
    } else |_| {}

    const f = try std.fs.cwd().createFile(name, .{});
    defer f.close();
    var bw = std.io.bufferedWriter(f.writer());
    for (0..size) |_| try bw.writer().writeByte(switch (rng.random().uintLessThanBiased(u8, 26 + 26 + 10)) {
        0...25 => |o| o + 'a',
        26...51 => |o| o - 26 + 'A',
        else => |o| o - 52 + '0',
    });
    try bw.flush();
}

fn generateFiles() !void {
    const seed: u64 = @intCast(std.time.microTimestamp());
    var timer = try std.time.Timer.start();

    var rng = std.Random.DefaultPrng.init(seed);
    try generateFile("small.data", (1 << 12) - 1, &rng);
    try generateFile("medium.data", (1 << 21) - 1, &rng);
    try generateFile("large.data", (1 << 28) - 1, &rng);
    std.debug.print("data file generation took: {}\n\n", .{std.fmt.fmtDuration(timer.read())});
}

test {
    try generateFiles();

    const file_name = "small.data";

    const old_res = blk: {
        var file_handle = try std.fs.cwd().openFile(file_name, .{});
        defer file_handle.close();
        break :blk original.getCrc32(file_handle.reader().any());
    };
    const new_res = blk: {
        var file_handle = try std.fs.cwd().openFile(file_name, .{});
        defer file_handle.close();
        break :blk solution.getCrc32(file_handle.reader().any());
    };

    try std.testing.expectEqual(old_res, new_res);
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

    try generateFiles();
    const file_name = "medium.data";

    var timer = try std.time.Timer.start();
    if (!skip_original) {
        var file_handle = try std.fs.cwd().openFile(file_name, .{});
        defer file_handle.close();
        std.mem.doNotOptimizeAway(original.getCrc32(file_handle.reader().any()));
    }
    const old_time = timer.lap();
    if (!skip_solution) {
        var file_handle = try std.fs.cwd().openFile(file_name, .{});
        defer file_handle.close();
        std.mem.doNotOptimizeAway(solution.getCrc32(file_handle.reader().any()));
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
