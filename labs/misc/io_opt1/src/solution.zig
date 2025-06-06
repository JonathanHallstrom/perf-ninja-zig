const std = @import("std");

pub fn getCrc32(reader: std.io.AnyReader) u32 {
    var hasher = std.hash.Crc32.init();

    while (reader.readByte()) |byte| {
        hasher.update(&.{byte});
    } else |_| {
        // got EOF
    }

    return hasher.final();
}
