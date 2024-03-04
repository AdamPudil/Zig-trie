const std = @import("std");

pub const VERSION = "1.0";

pub const Trie = struct {
    root: *Node,
    allocator: *std.mem.Allocator,

    pub const errors = error{ childrenNodeAllocation, wordDesntExist };

    pub const Node = struct {
        children: [256]?*Node,
        sentnce_end_cnt: i64,
        allocator: *std.mem.Allocator,

        fn init(allocator: *std.mem.Allocator) !Node {
            var ret = Node{
                .children = undefined,
                .sentnce_end_cnt = 0,
                .allocator = allocator,
            };

            for (&ret.children) |*child| {
                child.* = null;
            }

            return ret;
        }

        fn insert(self: *Node, word: []const u8) !void {
            if (word.len == 0) {
                self.sentnce_end_cnt += 1;
                return;
            }

            if (self.children[word[0]]) |nnchild| {
                try nnchild.insert(word[1..]);
            } else {
                var tmp_node: *Node = try self.allocator.create(Node);
                tmp_node.* = try Node.init(self.allocator);
                self.children[word[0]] = tmp_node;

                try self.children[word[0]].?.insert(word[1..]);
            }
        }

        fn contains(self: *Node, word: []const u8) !i64 {
            if (word.len == 0) {
                return self.sentnce_end_cnt;
            }

            if (self.children[word[0]]) |nonopt_next_node| {
                return nonopt_next_node.contains(word[1..]);
            } else {
                return 0;
            }
        }

        fn delete(self: *Node, word: []const u8) !void {
            if (word.len == 0) {
                if (self.sentnce_end_cnt <= 0) {
                    return errors.wordDesntExist;
                }

                for (self.children) |child| {
                    if (child) |_| {
                        self.sentnce_end_cnt -= 1;
                        return;
                    }
                }

                if (self.sentnce_end_cnt == 1) {
                    self.sentnce_end_cnt = -1;
                    return;
                }

                self.sentnce_end_cnt -= 1;
                return;
            }

            if (self.children[word[0]]) |nonopt_next_node| {
                try nonopt_next_node.delete(word[1..]);

                if (nonopt_next_node.sentnce_end_cnt == -1) {
                    self.allocator.destroy(nonopt_next_node); // Corrected destroy call
                    self.children[word[0]] = null;
                }

                return;
            } else {
                return errors.wordDesntExist;
            }
        }

        //fn get_size(self: *Node) usize {
        //var size : usize = 0;

        //var +=

        //return size;
        //}

        fn deinit(self: *Node) void {
            for (&self.children, 0..) |*child, index| {
                if (child.* != null) {
                    self.children[index].?.deinit();
                    self.allocator.destroy(child.*.?); // Corrected destroy call
                    child.* = null; // Explicitly set to null after destruction
                }
            }
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

    pub fn get_size(self: *Trie) usize {
        return self.root.get_size();
    }

    pub fn deinit(self: *Trie) void {
        self.root.deinit();
        self.allocator.destroy(self.root);
    }
};
