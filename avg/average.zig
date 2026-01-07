const std = @import("std");

fn average(data: []const f64) f64 {
    var sum: f64 = 0.0;
    var count: usize = 0;

    for (data) |v| {
        sum += v;
        count += 1;
    }

    return sum / @as(f64, @floatFromInt(count));
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const start_total = std.time.nanoTimestamp();

    const start_create = std.time.nanoTimestamp();
    const n = 100_000_000;
    var data = try std.ArrayList(f64).initCapacity(allocator, n);
    defer data.deinit(allocator);

    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rng = prng.random();

    var i: usize = 0;
    while (i < n) : (i += 1) {
        const val = rng.float(f64) * 200.0 - 100.0;  // range: -100 to 100
        data.appendAssumeCapacity(val);
    }
    const end_create = std.time.nanoTimestamp();

    const start_average = std.time.nanoTimestamp();
    const avg = average(data.items);
    const end_average = std.time.nanoTimestamp();

    const end_total = std.time.nanoTimestamp();

    const create_time = @as(f64, @floatFromInt(end_create - start_create)) / 1_000_000_000.0;
    const average_time = @as(f64, @floatFromInt(end_average - start_average)) / 1_000_000_000.0;
    const total_time = @as(f64, @floatFromInt(end_total - start_total)) / 1_000_000_000.0;

    std.debug.print("average = {d}\n", .{avg});
    std.debug.print("Data creation: {d:.6} seconds\n", .{create_time});
    std.debug.print("Averaging:     {d:.6} seconds\n", .{average_time});
    std.debug.print("Total:         {d:.6} seconds\n", .{total_time});
}
