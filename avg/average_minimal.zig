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

    const avg = averageSimdMinimal(data.items);
    std.debug.print("average = {d}\n", .{avg});
}
