const std = @import("std");

// `key` is guaranteed to be one of the elements of `items`
pub fn binarySearch(items: []u32, key: u32) usize {
    var low: usize = 0;
    var high: usize = items.len;

    while (low < high) {
        const mid = low + (high - low) / 2;
        if (items[mid] < key) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }
    return low;
}
