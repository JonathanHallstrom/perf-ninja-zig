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

    // note: you can get almost the same speedup unrolling manually
    // var res: u16 = 0;
    // var i: usize = 0;

    // if (std.simd.suggestVectorLength(u16)) |unroll|{
    //     var accs: @Vector(unroll, u16) = @splat(0);
    //     while (i + unroll - 1 < input.len) : (i += unroll) {
    //         const vals: @Vector(unroll, u16) = input[i..][0..unroll].*;
    //         accs +%= vals;
    //         const zeroes: @Vector(unroll, u16) = @splat(0);
    //         const ones: @Vector(unroll, u16) = @splat(1);
    //         accs +%= @select(u16, accs < vals, ones, zeroes);
    //     }
    //     for (@as([unroll]u16, accs)) |acc| {
    //         res +%= acc;
    //         res += @intFromBool(res < acc);
    //     }
    // }

    // for (input[i..]) |c| {
    //     const sum, const carry = @addWithOverflow(res, c);
    //     res = sum + carry;
    // }
    // return res;
}
