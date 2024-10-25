const std = @import("std");


// `key` is guaranteed to be one of the elements of `items`
pub fn binarySearch(items: []u32, key: u32) usize {
    var it: usize = 0;
    var len: usize = items.len;

    while (len > 1) {
        const half: usize = len / 2;
        len -= half;
        if (items[it + half - 1] < key) {
            it += half;
        }
    }

    return it;
}
