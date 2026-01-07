const std = @import("std");

// SIMD version with explicit no-unroll hint
fn averageSimd(data: []const f64) f64 {
    const VecSize = 8;
    const Vec = @Vector(VecSize, f64);

    var sum_vec: Vec = @splat(0.0);

    const vec_count = data.len / VecSize;

    // Prevent excessive loop unrolling
    var i: usize = 0;
    while (i < vec_count) {
        const offset = i * VecSize;
        const vec: Vec = data[offset..][0..VecSize].*;
        sum_vec += vec;
        i += 1;
    }

    var sum: f64 = 0.0;
    inline for (0..VecSize) |j| {
        sum += sum_vec[j];
    }

    i = vec_count * VecSize;
    while (i < data.len) : (i += 1) {
        sum += data[i];
    }

    return sum / @as(f64, @floatFromInt(data.len));
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

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

    const avg = averageSimd(data.items);
    std.debug.print("average = {d}\n", .{avg});
}
