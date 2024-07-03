const std = @import("std");
const color = @import("color.zig");
const vec3 = @import("vec3.zig");

pub fn main() !void {
    const image_width: u16 = 256;
    const image_height: u16 = 256;

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });
    var j: u16 = 0;
    while (j < image_height) : (j += 1) {
        var i: u16 = 0;
        std.debug.print("Scanlines remaining: {}\n", .{image_height - j});
        while (i < image_width) : (i += 1) {
            const r: f64 = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(image_width - 1));
            const g: f64 = @as(f64, @floatFromInt(j)) / @as(f64, @floatFromInt(image_height - 1));
            const b: f64 = 0.0;
            const pixel = color.color.init(r, g, b);
            try color.write_color(stdout, pixel);
        }
    }
    std.debug.print("Done.\n", .{});

    try bw.flush();
}
