const std = @import("std");

pub const infinity: f64 = std.math.inf(f64);
pub const pi: f64 = std.math.pi;

pub fn degrees_to_radians(degrees: f64) f64 {
    return degrees * pi / 180.0;
}

pub const random = struct {
    prng: std.Random.Xoshiro256,
    rand: std.Random,

    pub fn init(self: *random) !void {
        self.prng = std.Random.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            try std.posix.getrandom(std.mem.asBytes(&seed));
            break :blk seed;
        });
        self.rand = self.prng.random();
    }

    pub fn random_double(self: random) f64 {
        return self.rand.float(f64);
    }

    pub fn random_double_range(self: random, min: f64, max: f64) f64 {
        return min + (max - min) * self.random_double();
    }
};
