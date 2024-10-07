const std = @import("std");

pub fn checksum(input: []u8) u16 {
    var res: u16 = 0;
    for (input) |c| {
        const sum, const carry = @addWithOverflow(res, c);
        res = sum + carry;
    }
    return res;
}
