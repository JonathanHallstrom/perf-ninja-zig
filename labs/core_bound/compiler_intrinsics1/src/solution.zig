const std = @import("std");

pub fn imageSmoothing(input: []u8, radius: u8, output: []u16) void {
    std.debug.assert(input.len == output.len);
    const size = input.len;
    std.debug.assert(size >= radius);

    var currentSum: u16 = 0;
    for (0..@min(size, radius)) |i| {
        currentSum += input[i];
    }

    var pos: usize = 0;
    while (pos < @min(radius + 1, size - radius)) : (pos += 1) {
        currentSum += input[pos + radius];
        output[pos] = currentSum;
    }

    const unroll = std.simd.suggestVectorLength(u16) orelse 8;

    while (pos + unroll - 1 < size - radius) : (pos += unroll) {
        const sub: @Vector(unroll, i16) = input[pos - radius - 1..][0..unroll].*;
        const add: @Vector(unroll, i16) = input[pos + radius..][0..unroll].*;

        const prefix = std.simd.prefixScan(.Add, 1, add - sub);

        for (0..unroll) |i| output[pos + i] = @intCast(@as(i32, currentSum) + prefix[i]);
        currentSum = @intCast(@as(i32, currentSum) + prefix[unroll - 1]);
    }

    while (pos < size - radius) : (pos += 1) {
        currentSum -= input[pos - radius - 1];
        currentSum += input[pos + radius];
        output[pos] = currentSum;
    }

    while (pos < @min(radius + 1, size)) : (pos += 1) {
        output[pos] = currentSum;
    }

    while (pos < size) : (pos += 1) {
        currentSum -= input[pos - radius - 1];
        output[pos] = currentSum;
    }
}
