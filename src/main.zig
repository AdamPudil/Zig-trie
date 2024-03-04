const std = @import("std");
const Trie = @import("trie.zig").Trie;

pub fn main() !void {
    var allocator = std.heap.page_allocator;

    var trie: Trie = try Trie.init(&allocator);

    try trie.insert("hello");
    std.debug.print("Result: {any}\n", .{try trie.contains("hello")});
    try trie.delete("hello");
    std.debug.print("Result: {any}\n", .{try trie.contains("hello")});

    trie.deinit();
}
