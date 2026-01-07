const std = @import("std");
const builtin = @import("builtin");

// High-performance SIMD average with multiple accumulators
// for better instruction-level parallelism
fn averageSimd(data: []const f64) f64 {
    const VecSize = 8; // AVX-512: 8 doubles per vector
    const Vec = @Vector(VecSize, f64);
    const NumAccums = 4; // Multiple accumulators for ILP

    // Multiple vector accumulators to exploit instruction-level parallelism
    var sums: [NumAccums]Vec = undefined;
    for (&sums) |*sum| {
        sum.* = @splat(0.0);
    }

    const chunk_size = VecSize * NumAccums;
    const chunk_count = data.len / chunk_size;
    var i: usize = 0;

    // Process NumAccums vectors at a time
    while (i < chunk_count) : (i += 1) {
        const offset = i * chunk_size;
        inline for (0..NumAccums) |j| {
            const vec_offset = offset + j * VecSize;
            const vec: Vec = data[vec_offset..][0..VecSize].*;
            sums[j] += vec;
        }
    }

    // Reduce all accumulator vectors to one
    var final_sum: Vec = @splat(0.0);
    for (sums) |sum| {
        final_sum += sum;
    }

    // Horizontal sum of final vector
    var total: f64 = 0.0;
    inline for (0..VecSize) |j| {
        total += final_sum[j];
    }

    // Handle remaining elements
    i = chunk_count * chunk_size;
    while (i < data.len) : (i += 1) {
        total += data[i];
    }

    return total / @as(f64, @floatFromInt(data.len));
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
    const avg = averageSimd(data.items);
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
