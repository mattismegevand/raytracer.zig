const std = @import("std");

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

            const ir: u16 = @as(u16, @intFromFloat(255.999 * r));
            const ig: u16 = @as(u16, @intFromFloat(255.999 * g));
            const ib: u16 = @as(u16, @intFromFloat(255.999 * b));

            try stdout.print("{} {} {}\n", .{ ir, ig, ib });
        }
    }
    std.debug.print("Done.\n", .{});

    try bw.flush();
}
