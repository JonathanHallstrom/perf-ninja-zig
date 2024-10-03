const std = @import("std");

pub const Dynamic = struct {
    func: *const fn (x: *usize) void,

    pub fn init(f: *const fn (x: *usize) void) @This() {
        return .{
            .func = f,
        };
    }

    pub fn handle(self: @This(), x: *usize) void {
        self.func(x);
    }
};

pub fn one(x: *usize) void {
    x.* += 1;
}

pub fn two(x: *usize) void {
    x.* += 2;
}

pub fn three(x: *usize) void {
    x.* += 3;
}
