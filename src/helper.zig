const std = @import("std");

pub const infinity: f64 = std.math.inf(f64);
pub const pi: f64 = std.math.pi;

pub fn degrees_to_radians(degrees: f64) f64 {
    return degrees * pi / 180.0;
}
