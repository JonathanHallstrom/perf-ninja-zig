const std = @import("std");

fn mapToBucket(v: i32) usize {
    return switch (v) {
        //   size of a bucket
        0...13 => 0, //   13
        14...29 => 1, //   16
        30...41 => 2, //   12
        42...53 => 3, //   12
        54...71 => 4, //   18
        72...83 => 5, //   12
        84...100 => 6, //   17
        else => 7,
    };
}

pub fn histogram(values: []i32) [8]usize {
    var buckets: [8]usize = .{0} ** 8;
    for (values) |e| {
        buckets[mapToBucket(e)] += 1;
    }
    return buckets;
}
