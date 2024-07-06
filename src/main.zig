const std = @import("std");
const color = @import("color.zig");
const ray = @import("ray.zig").ray;
const vec3 = @import("vec3.zig").vec3;
const point3 = @import("vec3.zig").point3;
const hit_record = @import("hittable.zig").hit_record;
const hittable = @import("hittable.zig").hittable;
const hittable_list = @import("hittable_list.zig").hittable_list;
const sphere = @import("sphere.zig").sphere;
const helper = @import("helper.zig");
const interval = @import("interval.zig").interval;

fn ray_color(r: ray, world: hittable_list) color.color {
    var rec: hit_record = undefined;
    if (world.hit(r, interval.init(0, helper.infinity), &rec)) {
        return rec.normal.add(color.color.init(1, 1, 1)).scale(0.5);
    }

    const unit_direction: vec3 = r.direction.unit_vector();
    const a: f64 = 0.5 * (unit_direction.y + 1.0);
    return color.color.init(1.0, 1.0, 1.0).scale(1.0 - a).add(color.color.init(0.5, 0.7, 1.0).scale(a));
}

pub fn main() !void {
    const aspect_ratio: f64 = 16.0 / 9.0;
    const image_width: u16 = 400;

    var image_height: u16 = @as(f64, @floatFromInt(image_width)) / aspect_ratio;
    image_height = if (image_height < 1) 1 else image_height;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var world = hittable_list{ .objects = std.ArrayList(hittable).init(allocator) };
    defer world.objects.deinit();

    try world.objects.append(hittable{ .sphere = sphere.init(point3.init(0, 0, -1), 0.5) });
    try world.objects.append(hittable{ .sphere = sphere.init(point3.init(0, -100.5, -1), 100) });

    const focal_length: f64 = 1.0;
    const viewport_height: f64 = 2.0;
    const viewport_width: f64 = viewport_height * (@as(f64, @floatFromInt(image_width)) / @as(f64, @floatFromInt(image_height)));
    const camera_center: point3 = point3.zero();

    const viewport_u: vec3 = vec3.init(viewport_width, 0, 0);
    const viewport_v: vec3 = vec3.init(0, -viewport_height, 0);

    const pixel_delta_u: vec3 = viewport_u.scale(1.0 / @as(f64, @floatFromInt(image_width)));
    const pixel_delta_v: vec3 = viewport_v.scale(1.0 / @as(f64, @floatFromInt(image_height)));

    const viewport_upper_left = camera_center.sub(vec3.init(0, 0, focal_length)).sub(viewport_u.scale(0.5)).sub(viewport_v.scale(0.5));
    const pixel00_loc: point3 = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).scale(0.5));

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });
    var j: u16 = 0;
    while (j < image_height) : (j += 1) {
        var i: u16 = 0;
        std.debug.print("Scanlines remaining: {}\n", .{image_height - j});
        while (i < image_width) : (i += 1) {
            const pixel_center: point3 = pixel00_loc.add(pixel_delta_u.scale(@as(f64, @floatFromInt(i))).add(pixel_delta_v.scale(@as(f64, @floatFromInt(j)))));
            const ray_direction: vec3 = pixel_center.sub(camera_center);
            const r: ray = ray.init(camera_center, ray_direction);

            const pixel_color: color.color = ray_color(r, world);
            try color.write_color(stdout, pixel_color);
        }
    }
    std.debug.print("Done.\n", .{});

    try bw.flush();
}
