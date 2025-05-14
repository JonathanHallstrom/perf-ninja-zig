const std = @import("std");

const original = @import("original.zig");
const solution = @import("solution.zig");
const List = std.SinglyLinkedList(u32);

fn makeList(n: usize, allocator: std.mem.Allocator, rng: std.Random) !List {
    const random_vals = try allocator.alloc(u32, n);
    defer allocator.free(random_vals);
    for (random_vals) |*e| e.* = rng.uintAtMost(u32, std.math.maxInt(u32));
    std.sort.pdq(u32, random_vals, void{}, std.sort.asc(u32));
    var last: u32 = random_vals[0] +% 1;
    var actual_count: usize = 0;
    for (random_vals) |e| {
        random_vals[actual_count] = e;
        actual_count += @intFromBool(e != last);
        last = e;
    }
    rng.shuffle(u32, random_vals);

    var res = List{};
    errdefer {
        var iter = res.first;
        while (iter) |it| {
            const nx = it.next;
            allocator.destroy(it);
            iter = nx;
        }
    }

    for (random_vals[0..actual_count]) |e| {
        res.prepend(try allocator.create(List.Node));
        res.first.?.data = e;
    }

    return res;
}

test {
    const seed: u64 = @intCast(std.time.microTimestamp());

    var rng = std.Random.DefaultPrng.init(seed);

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const n = 1 << 10;
    const input_a = try makeList(n, allocator, rng.random());
    const input_b = try makeList(n, allocator, rng.random());
    try std.testing.expectEqual(original.solution(input_a, input_b), solution.solution(input_a, input_b));
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

    const n = 10 << 10;
    const input_a = try makeList(n, allocator, rng.random());
    const input_b = try makeList(n, allocator, rng.random());

    var timer = try std.time.Timer.start();
    if (!skip_original) {
        for (0..8) |_| {
            std.mem.doNotOptimizeAway(original.solution(input_a, input_b));
        }
    }
    const old_time = timer.lap();
    if (!skip_solution) {
        for (0..8) |_| {
            std.mem.doNotOptimizeAway(solution.solution(input_a, input_b));
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
