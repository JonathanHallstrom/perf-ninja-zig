const std = @import("std");

pub fn sum(x: u32) f64 {
    var res: f64 = 0;
    for (0..x) |i| {
        res += @floatFromInt(i);
    }
    return res;
}
