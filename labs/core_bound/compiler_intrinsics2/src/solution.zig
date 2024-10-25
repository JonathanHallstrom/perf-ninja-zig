const std = @import("std");

pub fn longestLine(input: []const u8) usize {
    var longest: usize = 0;

    // simple idiomatic solution, 
    // around 78% faster on MarkTwain-TomSawyer.txt
    // around 87% faster on udivmodti4_test.zig
    // var it = std.mem.splitScalar(u8, input, '\n');
    // while (it.next()) |line| longest = @max(longest, line.len);

    // faster solution
    var current: usize = 0;
    var i: usize = 0;
    if (std.simd.suggestVectorLength(u8)) |unroll| {
        // around 87% faster on MarkTwain-TomSawyer.txt
        // around 92% faster on udivmodti4_test.zig
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
        // around 81% faster on MarkTwain-TomSawyer.txt
        // around 82% faster on udivmodti4_test.zig
        // SWAR solution if SIMD isn't available
        // techniques inspired by https://lemire.me/blog/2017/01/20/how-quickly-can-you-remove-spaces-from-a-string/
        const unroll = @sizeOf(usize);
        while (i + unroll - 1 < input.len) {
            // do little endian read even on big endian systems for simpler code
            // could theoretically handle both separately but a byte swap is really cheap anyway
            const buf = std.mem.readInt(usize, input[i..][0..unroll], .little);
            
            const new_lines = std.math.maxInt(usize) / 255 * '\n';

            const lowest_bits = std.math.maxInt(usize) / 255 * 0x01;
            const highest_bits = std.math.maxInt(usize) / 255 * 0x80;

            const check = buf ^ new_lines;
            const is_newline = check -% lowest_bits & ~check & highest_bits;
            if (is_newline != 0) {
                const leading_zeros = @ctz(is_newline) / 8;
                longest = @max(longest, current + leading_zeros);
                current = 0;
                i += leading_zeros + 1;
            } else {
                current += unroll;
                i += unroll;
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
