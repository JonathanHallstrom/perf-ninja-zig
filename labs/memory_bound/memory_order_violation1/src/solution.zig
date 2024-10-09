const std = @import("std");

pub fn histogram(image: []const u8) [256]u32 {
    var res: [256]u32 = .{0} ** 256;
    for (image) |pixel| res[pixel] += 1;
    return res;
}
