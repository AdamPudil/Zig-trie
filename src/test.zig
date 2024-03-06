const std = @import("std");

const testing = std.testing;
const Trie = @import("trie.zig").Trie;
const version = @import("trie.zig").VERSION;

test "insert and search" {
    var allocator = std.testing.allocator;

    const start = std.time.nanoTimestamp();
    defer {
        const end = std.time.nanoTimestamp();
        const duration = @as(u64, @intCast(end - start));
        std.debug.print(" Test ran for {d}\n\n", .{std.fmt.fmtDuration(duration)});
    }

    var trie: Trie = try Trie.init(&allocator);
    defer trie.deinit();

    try trie.insert("hello");
    try trie.insert("world");
    try trie.insert("hello");

    try testing.expect(try trie.contains("hello") == 2);
    try testing.expect(try trie.contains("world") == 1);
    try testing.expect(try trie.contains("zig") == 0);

    std.debug.print("\n Maximal used memory: {any}\n", .{std.fmt.fmtIntSizeDec(trie.get_size())});
}

test "delete word" {
    var allocator = std.testing.allocator;

    const start = std.time.nanoTimestamp();
    defer {
        const end = std.time.nanoTimestamp();
        const duration = @as(u64, @intCast(end - start));
        std.debug.print(" Test ran for {d}\n\n", .{std.fmt.fmtDuration(duration)});
    }

    var trie: Trie = try Trie.init(&allocator);
    defer trie.deinit();

    try trie.insert("hello");
    try testing.expect(try trie.contains("hello") == 1);

    std.debug.print("\n Maximal used memory: {any}\n", .{std.fmt.fmtIntSizeDec(trie.get_size())});

    try trie.delete("hello");

    try testing.expect(try trie.contains("hello") == 0);

    // delete after delete
    if (trie.delete("hello")) {
        std.debug.print(" No error raised!\n", .{});
    } else |err| switch (err) {
        Trie.errors.wordDesntExist => std.debug.print(" Right error raised {any}\n", .{err}),

        else => {
            std.debug.print(" Wrong error raised {any}!\n", .{err});
            try std.testing.expect(false);
        },
    }

    // delete of substring
    try trie.insert("hello world");

    if (trie.delete("hello")) {
        std.debug.print(" No error raised!\n", .{});
    } else |err| switch (err) {
        Trie.errors.wordDesntExist => std.debug.print(" Right error raised {any}\n", .{err}),

        else => {
            std.debug.print(" Wrong error raised {any}!\n", .{err});
            try std.testing.expect(false);
        },
    }
}

test "Mainly performance oriented test" {
    var allocator = std.testing.allocator;

    const baseSentences = &[_][]const u8{
        "The quick brown fox jumps over the lazy dog",
        "The quick brown fox jumps over the lazy dog again",
        "The quick brown fox jumps over the lazy dog for the third time",
        "The quick brown fox jumps over the lazy dog and meets another fox",
        "The quick brown fox jumps over the lazy dog but this time it's different",
        "A journey of a thousand miles begins with a single step",
        "A journey of a thousand miles begins with a single step into the unknown",
        "A journey of a thousand miles begins with a single step, but this step is taken with a friend",
        "To be or not to be, that is the question",
        "To be or not to be, that is the question we all face",
        "To be or not to be, that is the question we all face in life's great journey",
        "An apple a day keeps the doctor away",
        "An apple a day keeps the doctor away, but only if you aim well",
        "An apple a day keeps the doctor away, but only if you aim well and throw hard enough",
        "Early to bed and early to rise makes a man healthy, wealthy, and wise",
        "Early to bed and early to rise makes a man healthy, wealthy, and wise, or so they say",
        "Early to bed and early to rise makes a man healthy, wealthy, and wise, but life is rarely so simple",
        "In the end, we only regret the chances we didn't take",
        "In the end, we only regret the chances we didn't take and the words we never said",
        "In the end, we only regret the chances we didn't take, the words we never said, and the love we never allowed ourselves to feel",
        "In the midst of chaos, there is also opportunity",
        "In the midst of chaos, there is also opportunity for those who look hard enough",
        "In the midst of chaos, there is also opportunity for those who look hard enough and dare to grab it",
        "What we think, we become",
        "What we think, we become, and so our thoughts shape our destiny",
        "What we think, we become, and so our thoughts shape our destiny, guiding us towards our ultimate fate",
        "Life is 10% what happens to us and 90% how we react to it",
        "Life is 10% what happens to us and 90% how we react to it, thus control lies within our responses",
        "Life is 10% what happens to us and 90% how we react to it, thus control lies within our responses, shaping our journey",
        "The only way to do great work is to love what you do",
        "The only way to do great work is to love what you do, as passion fuels excellence",
        "The only way to do great work is to love what you do, as passion fuels excellence and drives us towards success",
        "It does not matter how slowly you go as long as you do not stop",
        "It does not matter how slowly you go as long as you do not stop, for persistence is the key to achievement",
        "It does not matter how slowly you go as long as you do not stop, for persistence is the key to achievement in all endeavors",
        "Success is not the key to happiness. Happiness is the key to success",
        "Success is not the key to happiness. Happiness is the key to success, and loving what you do is the secret",
        "Success is not the key to happiness. Happiness is the key to success, and loving what you do is the secret to a fulfilled life",
        "Change your thoughts and you change your world",
        "Change your thoughts and you change your world, as the mind has the power to reshape reality",
        "Change your thoughts and you change your world, as the mind has the power to reshape reality and create our future",
        "The best time to plant a tree was 20 years ago. The second best time is now",
        "The best time to plant a tree was 20 years ago. The second best time is now, for it's never too late to make a difference",
        "The best time to plant a tree was 20 years ago. The second best time is now, for it's never too late to make a difference and contribute to the future",
        "Only a life lived for others is a life worthwhile",
        "Only a life lived for others is a life worthwhile, as true fulfillment comes from giving",
        "Only a life lived for others is a life worthwhile, as true fulfillment comes from giving and sharing our gifts with the world",
    };

    std.debug.print("\n This test is used to measure performance and memory footprint improovments. \n Trie version: {s}\n", .{version});

    const start = std.time.nanoTimestamp();
    defer {
        const end = std.time.nanoTimestamp();
        const duration = @as(u64, @intCast(end - start));
        std.debug.print(" Test ran for {d}\n\n", .{std.fmt.fmtDuration(duration)});
    }

    var trie: Trie = try Trie.init(&allocator);
    defer trie.deinit();

    var i: usize = 0;
    while (i < 1000) : (i += 1) {
        for (baseSentences) |sentence| {
            try trie.insert(sentence);
        }
    }

    std.debug.print(" Maximal used memory: {any}\n", .{std.fmt.fmtIntSizeDec(trie.get_size())});

    for (baseSentences) |sentence| {
        try testing.expectEqual(try trie.contains(sentence), 1000);
    }

    i = 0;
    while (i < 100) : (i += 1) {
        for (baseSentences[0..10]) |sentence| {
            try trie.delete(sentence);
        }
    }

    for (baseSentences[0..10]) |sentence| {
        try testing.expectEqual(try trie.contains(sentence), 900);
    }

    i = 0;
    while (i < 900) : (i += 1) {
        for (baseSentences[0..20]) |sentence| {
            try trie.delete(sentence);
        }
    }

    for (baseSentences[0..10]) |sentence| {
        try testing.expectEqual(try trie.contains(sentence), 0);
    }

    for (baseSentences[10..20]) |sentence| {
        try testing.expectEqual(try trie.contains(sentence), 100);
    }
}
