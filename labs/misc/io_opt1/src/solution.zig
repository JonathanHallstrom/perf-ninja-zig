const std = @import("std");

pub fn getCrc32(reader: anytype) u32 {
    var hasher = std.hash.Crc32.init();

    var buf: [1 << 21]u8 = undefined;
    while (reader.read(&buf)) |amt_read| {
        if (amt_read == 0) break;
        hasher.update(buf[0..amt_read]);
    } else |e| {
        std.debug.panic("error: {}\n", .{e});
    }

    return hasher.final();
}
