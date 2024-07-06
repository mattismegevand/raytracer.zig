const std = @import("std");

pub const infinity: f64 = std.math.inf(f64);
pub const pi: f64 = std.math.pi;

pub fn degrees_to_radians(degrees: f64) f64 {
    return degrees * pi / 180.0;
}

pub const helper = undefined;

var prng: std.Random.Xoshiro256 = undefined;
var rand: std.Random = undefined;

pub fn random_init() !void {
    prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    rand = prng.random();
}

pub fn random_double() f64 {
    return rand.float(f64);
}

pub fn random_double_range(min: f64, max: f64) f64 {
    return min + (max - min) * random_double();
}
