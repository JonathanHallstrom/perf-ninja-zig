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
