pub const Position = extern struct {
    x: u32,
    y: u32,
    z: u32,
};

comptime {
    // if any of these fail, please make an issue on the repo with your arch!
    const assert = @import("std").debug.assert;
    assert(@sizeOf(Position) == 3 * @sizeOf(u32));
    const tmp: [3]u32 = @bitCast(Position{ .x = 0, .y = 1, .z = 2 });
    assert(tmp[0] == 0);
    assert(tmp[1] == 1);
    assert(tmp[2] == 2);
}
