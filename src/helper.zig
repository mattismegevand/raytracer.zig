const std = @import("std");

pub const infinity = std.math.inf(f64);
pub const pi = std.math.pi;

pub fn degreesToRadians(degrees: f64) f64 {
    return degrees * pi / 180.0;
}

var prng: ?std.Random.Xoshiro256 = null;
var rand: ?std.Random = null;

pub fn randomInit() !void {
    if (prng == null) {
        prng = std.Random.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            try std.posix.getrandom(std.mem.asBytes(&seed));
            break :blk seed;
        });
        rand = prng.?.random();
    }
}

pub fn randomDouble() f64 {
    return rand.?.float(f64);
}

pub fn randomDoubleRange(min: f64, max: f64) f64 {
    return min + (max - min) * randomDouble();
}
