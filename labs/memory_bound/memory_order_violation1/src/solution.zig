const std = @import("std");

pub fn histogram(image: []const u8) [256]u32 {
    const unroll = 6;
    var accumulators: [unroll]@Vector(256, u32) = undefined;
    @memset(std.mem.asBytes(&accumulators), 0);
    var i: usize = 0;
    while (i + unroll - 1 < image.len) : (i += unroll) {
        for (0..unroll) |j| accumulators[j][image[i + j]] += 1;
    }
    for (image[i..]) |pixel| accumulators[0][pixel] += 1;
    for (1..unroll) |j| accumulators[0] += accumulators[j];
    return accumulators[0];
}