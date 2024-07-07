const std = @import("std");
const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;
const Interval = @import("interval.zig").Interval;

pub const Color = Vec3;

pub fn linearToGamma(linear_component: f64) f64 {
    if (linear_component > 0) {
        return @sqrt(linear_component);
    }
    return 0;
}

pub fn writeColor(out: anytype, pixel_color: Color) !void {
    var r = pixel_color.x;
    var g = pixel_color.y;
    var b = pixel_color.z;

    r = linearToGamma(r);
    g = linearToGamma(g);
    b = linearToGamma(b);

    const intensity = Interval.init(0.000, 0.999);
    const rbyte = @as(i16, @intFromFloat(256 * intensity.clamp(r)));
    const gbyte = @as(i16, @intFromFloat(256 * intensity.clamp(g)));
    const bbyte = @as(i16, @intFromFloat(256 * intensity.clamp(b)));

    try out.print("{} {} {}\n", .{ rbyte, gbyte, bbyte });
}
