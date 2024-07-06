const std = @import("std");
const vec3 = @import("vec3.zig").vec3;
const interval = @import("interval.zig").interval;

pub const color = vec3;

pub fn write_color(out: anytype, pixel_color: color) !void {
    const r: f64 = pixel_color.x;
    const g: f64 = pixel_color.y;
    const b: f64 = pixel_color.z;

    const intensity: interval = interval.init(0.000, 0.999);
    const rbyte: i16 = @as(i16, @intFromFloat(256 * intensity.clamp(r)));
    const gbyte: i16 = @as(i16, @intFromFloat(256 * intensity.clamp(g)));
    const bbyte: i16 = @as(i16, @intFromFloat(256 * intensity.clamp(b)));

    try out.print("{} {} {}\n", .{ rbyte, gbyte, bbyte });
}
