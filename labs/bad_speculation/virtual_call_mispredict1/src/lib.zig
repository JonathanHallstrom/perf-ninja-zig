const std = @import("std");

pub const Dynamic = struct {
    func: *const fn (data: *usize) void,

    pub fn init(which: u8) @This() {
        return .{
            .func = switch (which) {
                inline 0...3 => |v| struct {
                    fn impl(data: *usize) void {
                        data.* += v + 1;
                    }
                }.impl,
                else => unreachable,
            },
        };
    }

    pub fn handle(self: @This(), x: *usize) void {
        self.func(x);
    }
};