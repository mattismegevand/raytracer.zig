const std = @import("std");
const vec3 = @import("vec3.zig").vec3;
const interval = @import("interval.zig").interval;

pub const color = vec3;

pub fn linear_to_gamma(linear_component: f64) f64 {
    if (linear_component > 0) {
        return @sqrt(linear_component);
    }
    return 0;
}

pub fn write_color(out: anytype, pixel_color: color) !void {
    var r: f64 = pixel_color.x;
    var g: f64 = pixel_color.y;
    var b: f64 = pixel_color.z;

    r = linear_to_gamma(r);
    g = linear_to_gamma(g);
    b = linear_to_gamma(b);

    const intensity: interval = interval.init(0.000, 0.999);
    const rbyte: i16 = @as(i16, @intFromFloat(256 * intensity.clamp(r)));
    const gbyte: i16 = @as(i16, @intFromFloat(256 * intensity.clamp(g)));
    const bbyte: i16 = @as(i16, @intFromFloat(256 * intensity.clamp(b)));

    try out.print("{} {} {}\n", .{ rbyte, gbyte, bbyte });
}
