const std = @import("std");

pub fn select(n: comptime_int, output: *[n][2]u32, input: *const [n][2]u32, lower: u32, upper: u32) usize {
    var count: usize = 0;
    for (input) |e| {
        output[count] = e;
        if (lower <= e[0] and e[0] <= upper) {
            count += 1;
        }
    }
    return count;
}
