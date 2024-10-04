const std = @import("std");

pub fn longestLine(input: []const u8) usize {
    var longest: usize = 0;

    // simple idiomatic solution, gives ~60% speedup
    // var it = std.mem.splitScalar(u8, input, '\n');
    // while (it.next()) |line| longest = @max(longest, line.len);

    // faster solution
    var current: usize = 0;
    var i: usize = 0;
    if (std.simd.suggestVectorLength(u8)) |unroll| {
        // around ~77% faster on my machine
        const CVec = @Vector(unroll, u8);
        const Mask = std.meta.Int(.unsigned, unroll);
        while (i + unroll - 1 < input.len) {
            const buf: CVec = input[i..][0..unroll].*;

            const newlines: CVec = @splat('\n');
            const is_newline: Mask = @bitCast(buf == newlines);

            if (is_newline != 0) {
                const leading_zeros = @ctz(is_newline);
                longest = @max(longest, current + leading_zeros);
                current = 0;
                i += leading_zeros + 1;
            } else {
                current += unroll;
                i += unroll;
            }
        }
        longest = @max(longest, current);
    } else {
        // around 73% faster on my machine
        // SWAR solution if SIMD isn't available
        // techniques inspired by https://lemire.me/blog/2017/01/20/how-quickly-can-you-remove-spaces-from-a-string/
        while (i + 7 < input.len) {
            // do little endian read even on big endian systems for simpler code
            // could theoretically handle both separately but a byte swap is really cheap anyway
            const buf: u64 = std.mem.readInt(u64, input[i..][0..8], .little);
            
            const new_lines = std.math.maxInt(u64) / 255 * '\n';

            const high_bits_mask = 0x0101010101010101;
            const zero_byte_mask = 0x8080808080808080;

            const check = buf ^ new_lines;
            const is_newline = check -% high_bits_mask & ~check & zero_byte_mask;
            if (is_newline != 0) {
                const leading_zeros = @ctz(is_newline) / 8;
                longest = @max(longest, current + leading_zeros);
                current = 0;
                i += leading_zeros + 1;
            } else {
                current += 8;
                i += 8;
            }
        }
        longest = @max(longest, current);
    }
    for (input[i..]) |c| {
        current = if (c == '\n') 0 else current + 1;
        longest = @max(longest, current);
    }
    return longest;
}
