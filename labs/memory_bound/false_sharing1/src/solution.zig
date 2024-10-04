const std = @import("std");

const Allocator = std.mem.Allocator;

const Accumulator = struct {
    value: std.atomic.Value(u32) align(64) = std.atomic.Value(u32).init(0),
};

fn work(data: []u32, target: *Accumulator) void {
    for (data) |e| {
        var item = e;
        item += 1000;
        item ^= 0xADEDAE;
        item |= item >> 24;
        _ = target.value.fetchAdd(item % 13, .seq_cst);
    }
}

pub fn solution(data: []u32, thread_count: usize, allocator: Allocator) !usize {
    const accumulators: []Accumulator = try allocator.alloc(Accumulator, thread_count);
    defer allocator.free(accumulators);

    const threads: []std.Thread = try allocator.alloc(std.Thread, thread_count);
    defer allocator.free(threads);

    const amount_per_thread = (data.len + thread_count - 1) / thread_count;
    var work_idx: usize = 0;
    for (0..thread_count) |thread_idx| {
        defer work_idx += amount_per_thread;

        const remaining = data.len - work_idx;

        const slice_to_work_on = data[work_idx..][0..@min(remaining, amount_per_thread)];
        threads[thread_idx] = try std.Thread.spawn(.{}, work, .{ slice_to_work_on, &accumulators[thread_idx] });
    }

    for (0..thread_count) |thread_idx| {
        threads[thread_idx].join();
    }
    var res: usize = 0;
    for (accumulators) |accumulator| res += accumulator.value.load(.seq_cst);
    return res;
}
