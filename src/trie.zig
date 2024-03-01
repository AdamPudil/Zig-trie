const std = @import("std");

pub const Trie = struct {
    root: *Node,
    allocator: *std.mem.Allocator,

    pub const errors = error{ childrenNodeAllocation, wordDesntExist };

    pub const Node = struct {
        children: std.AutoArrayHashMap(u8, *Node),
        sentnce_end_cnt: i64,
        allocator: *std.mem.Allocator,

        fn init(allocator: *std.mem.Allocator) !Node {
            var ret = Node{
                .children = undefined,
                .sentnce_end_cnt = 0,
                .allocator = allocator,
            };

            ret.children = std.AutoArrayHashMap(u8, *Node).init(allocator.*);

            return ret;
        }

        fn insert(self: *Node, word: []const u8) !void {
            if (word.len == 0) {
                self.sentnce_end_cnt += 1;
                return;
            }

            if (!self.children.contains(word[0])) {
                var tmp_node: *Node = try self.allocator.create(Node);
                tmp_node.* = try Node.init(self.allocator);
                try self.children.put(word[0], tmp_node);
            }

            var next_node: ?*Node = self.children.get(word[0]);

            if (next_node) |nonopt_next_node| {
                return nonopt_next_node.insert(word[1..]);
            } else {
                return errors.childrenNodeAllocation;
            }
        }

        fn contains(self: *Node, word: []const u8) !i64 {
            if (word.len == 0) {
                return self.sentnce_end_cnt;
            }

            var next_node: ?*Node = self.children.get(word[0]);

            if (next_node) |nonopt_next_node| {
                return nonopt_next_node.contains(word[1..]);
            } else {
                return 0;
            }
        }

        fn delete(self: *Node, word: []const u8) !void {
            if (word.len == 0) {
                if (self.children.count() == 0 and self.sentnce_end_cnt == 1) {
                    self.sentnce_end_cnt = -1;
                    return;
                }

                if (self.sentnce_end_cnt > 0) {
                    self.sentnce_end_cnt -= 1;
                    return;
                }

                return errors.wordDesntExist;
            }

            var next_node: ?*Node = self.children.get(word[0]);

            if (next_node) |nonopt_next_node| {
                try nonopt_next_node.delete(word[1..]);

                if (nonopt_next_node.sentnce_end_cnt == -1) {
                    if (self.children.orderedRemove(word[0])) {
                        return;
                    }
                }

                return;
            } else {
                return errors.wordDesntExist;
            }
        }

        fn deinit(self: *Node) void {
            var child_it = self.children.iterator();

            while (child_it.next()) |entry| {
                const next_node = entry.value_ptr.*;
                next_node.deinit();
            }

            self.children.deinit();
        }
    };

    pub fn init(allocator: *std.mem.Allocator) !Trie {
        var ret = Trie{
            .root = undefined,
            .allocator = allocator,
        };

        ret.root = try allocator.create(Node);
        ret.root.* = try Node.init(allocator);

        return ret;
    }

    pub fn insert(self: *Trie, word: []const u8) !void {
        try self.root.insert(word);
    }

    pub fn contains(self: *Trie, word: []const u8) !i64 {
        return self.root.contains(word);
    }

    pub fn delete(self: *Trie, word: []const u8) !void {
        try self.root.delete(word);
    }

    pub fn deinit(self: *Trie) void {
        self.root.deinit();
        self.allocator.destroy(self.root);
    }
};
