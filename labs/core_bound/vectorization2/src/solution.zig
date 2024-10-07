const std = @import("std");

pub fn checksum(input: []u8) u16 {
    const maximum_values = (std.math.maxInt(u32) - std.math.maxInt(u16)) / std.math.maxInt(u8);
    var res: u32 = 0;
    // if we process more than maximum_values at a time res might overflow
    for (0..(input.len + maximum_values - 1) / maximum_values) |i| {
        const start = maximum_values * i;
        const end = @min(start + maximum_values, input.len);
        for (input[start..end]) |c| {
            res += c;
        }
        res = (res & (1 << 16) - 1) + (res >> 16);
        res = (res & (1 << 16) - 1) + (res >> 16);
    }
    return @intCast(res);
}
