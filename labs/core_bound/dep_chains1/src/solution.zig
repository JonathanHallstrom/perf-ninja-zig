const std = @import("std");

const List = std.SinglyLinkedList(u32);

fn getSumDigits(x: u32) u32 {
    var sum: u32 = 0;
    var n = x;
    while (n > 0) {
        sum += n % 10;
        n /= 10;
    }
    return sum;
}

pub fn solution(a: List, b: List) u32 {
    var res: u32 = 0;
    var it_a = a.first;
    while (it_a != null) {
        const unroll = 64;
        var vals: [unroll]u32 = .{0} ** unroll;
        for (0..unroll) |i| {
            if (it_a) |head_a| {
                vals[i] = head_a.data;
                it_a = head_a.next;
            } else {
                vals[i] = vals[0];
            }
        }

        var it_b = b.first;
        while (it_b) |head_b| : (it_b = head_b.next) {
            var found = false;
            for (vals) |value| {
                if (head_b.data == value) {
                    found = true;
                }
            }
            if (found) {
                res += getSumDigits(head_b.data);
            }
        }
    }
    return res;
}
