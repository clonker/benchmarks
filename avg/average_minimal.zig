const std = @import("std");

// Minimal SIMD - single accumulator, let compiler decide unrolling
fn averageSimdMinimal(data: []const f64) f64 {
    const VecSize = 8;
    const Vec = @Vector(VecSize, f64);

    var sum_vec: Vec = @splat(0.0);
    var i: usize = 0;
    const vec_limit = (data.len / VecSize) * VecSize;

    // Simple loop - compiler will auto-unroll optimally
    while (i < vec_limit) {
        sum_vec += @as(Vec, data[i..][0..VecSize].*);
        i += VecSize;
    }

    // Horizontal reduction
    var sum: f64 = @reduce(.Add, sum_vec);

    // Tail elements
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

    var i: usize = 0;
    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rng = prng.random();

    while (i < n) : (i += 1) {
        data.appendAssumeCapacity(rng.float(f64) * 200.0 - 100.0);
    }
    const end_create = std.time.nanoTimestamp();

    const start_average = std.time.nanoTimestamp();
    const avg = averageSimdMinimal(data.items);
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
