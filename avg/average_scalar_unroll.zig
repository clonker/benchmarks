const std = @import("std");

// Scalar unrolling approach (like C++) - let compiler auto-vectorize
fn averageScalarUnroll(data: []const f64) f64 {
    // 8-way scalar unrolling
    var sum0: f64 = 0.0;
    var sum1: f64 = 0.0;
    var sum2: f64 = 0.0;
    var sum3: f64 = 0.0;
    var sum4: f64 = 0.0;
    var sum5: f64 = 0.0;
    var sum6: f64 = 0.0;
    var sum7: f64 = 0.0;

    const unroll_limit = data.len - (data.len % 8);
    var i: usize = 0;

    while (i < unroll_limit) : (i += 8) {
        sum0 += data[i];
        sum1 += data[i + 1];
        sum2 += data[i + 2];
        sum3 += data[i + 3];
        sum4 += data[i + 4];
        sum5 += data[i + 5];
        sum6 += data[i + 6];
        sum7 += data[i + 7];
    }

    var sum = sum0 + sum1 + sum2 + sum3 + sum4 + sum5 + sum6 + sum7;

    // Handle remaining elements
    while (i < data.len) : (i += 1) {
        sum += data[i];
    }

    return sum / @as(f64, @floatFromInt(data.len));
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
        const val = rng.float(f64) * 200.0 - 100.0;
        data.appendAssumeCapacity(val);
    }
    const end_create = std.time.nanoTimestamp();

    const start_average = std.time.nanoTimestamp();
    const avg = averageScalarUnroll(data.items);
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
