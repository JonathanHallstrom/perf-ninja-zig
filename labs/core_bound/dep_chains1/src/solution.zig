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
    while (it_a) |head_a| : (it_a = head_a.next) {
        const value = head_a.data;
        var it_b = b.first;
        while (it_b) |head_b| : (it_b = head_b.next) {
            if (head_b.data == value) {
                res += getSumDigits(value);
                break;
            }
        }
    }
    return res;
}
