const std = @import("std");

pub fn sum(x: u32) f64 {
    var res: u64 = 0;
    for (0..x) |i| {
        res += i;
    }
    return @floatFromInt(res);
}
