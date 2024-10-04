const std = @import("std");

pub fn longestLine(input: []const u8) usize {
    var longest: usize = 0;
    var current: usize = 0;
    for (input) |c| {
        current = if (c == '\n') 0 else current + 1;
        longest = @max(longest, current);
    }
    return longest;
}
