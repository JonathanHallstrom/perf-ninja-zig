const std = @import("std");

const Allocator = std.mem.Allocator;

pub fn Life(x_dim: comptime_int, y_dim: comptime_int) type {
    return struct {
        const Grid = [][]i32;

        const Self = @This();

        current: Grid,
        future: Grid,
        allocator: Allocator,

        fn initGrid(allocator: Allocator) !Grid {
            const res: Grid = try allocator.alloc([]i32, x_dim);
            errdefer allocator.free(res);

            var backing = try allocator.alloc(i32, x_dim * y_dim);
            for (res, 0..) |*col, i| {
                col.* = backing[i * y_dim ..][0..y_dim];
            }
            return res;
        }

        fn deinitGrid(allocator: Allocator, g: Grid) void {
            allocator.free(g[0].ptr[0 .. x_dim * y_dim]);
            allocator.free(g);
        }

        pub fn init(allocator: Allocator) !Self {
            const cur = try initGrid(allocator);
            errdefer deinitGrid(allocator, cur);
            const fut = try initGrid(allocator);
            return .{
                .current = cur,
                .future = fut,
                .allocator = allocator,
            };
        }

        pub fn initRandom(allocator: Allocator) !Self {
            return initRandomWithSeed(allocator, @intCast(@mod(std.time.nanoTimestamp(), (1 << 64))));
        }

        pub fn initRandomWithSeed(allocator: Allocator, seed: u64) !Self {
            var rng = std.Random.DefaultPrng.init(seed);
            const res = try Self.init(allocator);
            for (res.current) |col| {
                for (col) |*item| {
                    item.* = @intFromBool(rng.random().intRangeLessThan(i32, 0, 10) > 6);
                }
            }
            return res;
        }

        pub fn deinit(self: *Self) void {
            deinitGrid(self.allocator, self.current);
            deinitGrid(self.allocator, self.future);
        }

        pub fn reset(self: *Self, g: Grid) void {
            for (self.current, self.future, g) |cur, fut, new_vals| {
                @memcpy(cur, new_vals);
                @memcpy(fut, new_vals);
            }
        }

        pub fn getPopulationCount(self: Self) i32 {
            var sum: i32 = 0;
            for (self.current) |col| {
                for (col) |item| {
                    sum += item;
                }
            }
            return sum;
        }

        pub fn printCurrentGrid(self: Self) void {
            for (self.current) |col| {
                for (col) |item| {
                    std.debug.print("{} ", .{item});
                }
                std.debug.print("\n", .{});
            }
        }

        pub fn simulateNext(self: *Self) void {
            for (0..x_dim) |i| {
                for (0..y_dim) |j| {
                    var alive_neighbors: i32 = 0;
                    for (0..3) |p| {
                        for (0..3) |q| {
                            if (i + p < 1 or i + p > x_dim - 1 or
                                j + q < 1 or j + q > y_dim - 1) continue;
                            alive_neighbors += self.current[i + p - 1][j + q - 1];
                        }
                    }

                    alive_neighbors -= self.current[i][j];

                    self.future[i][j] = switch (alive_neighbors) {
                        0, 1 => 0,
                        2 => self.current[i][j],
                        3 => 1,
                        else => 0,
                    };
                }
            }
            std.mem.swap(Grid, &self.current, &self.future);
        }
    };
}
