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

pub const camera = struct {
    aspect_ratio: f64,
    image_width: u16,
    image_height: u16,
    center: point3,
    pixel00_loc: point3,
    pixel_delta_u: vec3,
    pixel_delta_v: vec3,
    samples_per_pixel: u16,
    pixel_samples_scale: f64,
    max_depth: u16,

    pub fn render(self: *camera, world: hittable_list) !void {
        try self.init();

        const stdout_file = std.io.getStdOut().writer();
        var bw = std.io.bufferedWriter(stdout_file);
        const stdout = bw.writer();

        try stdout.print("P3\n{} {}\n255\n", .{ self.image_width, self.image_height });
        var j: u16 = 0;
        while (j < self.image_height) : (j += 1) {
            var i: u16 = 0;
            std.debug.print("Scanlines remaining: {}\n", .{self.image_height - j});
            while (i < self.image_width) : (i += 1) {
                var pixel_color: color.color = color.color.zero();
                var sample: u16 = 0;
                while (sample < self.samples_per_pixel) : (sample += 1) {
                    const r: ray = self.get_ray(i, j);
                    pixel_color = pixel_color.add(self.ray_color(r, self.max_depth, world));
                }
                try color.write_color(stdout, pixel_color.scale(self.pixel_samples_scale));
            }
        }
        std.debug.print("Done.\n", .{});

        try bw.flush();
    }

    pub fn init(self: *camera) !void {
        // self.aspect_ratio = 1.0;
        // self.image_width = 100;
        self.samples_per_pixel = 100;
        // self.max_depth = 10;

        try helper.random_init();

        self.image_height = @as(u16, @intFromFloat(@as(f64, @floatFromInt(self.image_width)) / self.aspect_ratio));
        self.image_height = if (self.image_height < 1) 1 else self.image_height;

        self.pixel_samples_scale = 1.0 / @as(f64, @floatFromInt(self.samples_per_pixel));

        self.center = point3.zero();

        const focal_length: f64 = 1.0;
        const viewport_height: f64 = 2.0;
        const viewport_width: f64 = viewport_height * (@as(f64, @floatFromInt(self.image_width)) / @as(f64, @floatFromInt(self.image_height)));

        const viewport_u: vec3 = vec3.init(viewport_width, 0, 0);
        const viewport_v: vec3 = vec3.init(0, -viewport_height, 0);

        self.pixel_delta_u = viewport_u.scale(1.0 / @as(f64, @floatFromInt(self.image_width)));
        self.pixel_delta_v = viewport_v.scale(1.0 / @as(f64, @floatFromInt(self.image_height)));

        const viewport_upper_left = self.center.sub(vec3.init(0, 0, focal_length)).sub(viewport_u.scale(0.5)).sub(viewport_v.scale(0.5));
        self.pixel00_loc = viewport_upper_left.add(self.pixel_delta_u.add(self.pixel_delta_v).scale(0.5));
    }

    pub fn get_ray(self: camera, i: u16, j: u16) ray {
        const offset: vec3 = sample_square();
        const pixel_sample: point3 = self.pixel00_loc.add(self.pixel_delta_u.scale(@as(f64, @floatFromInt(i)) + offset.x)).add(self.pixel_delta_v.scale(@as(f64, @floatFromInt(j)) + offset.y));

        const ray_origin: vec3 = self.center;
        const ray_direction: vec3 = pixel_sample.sub(ray_origin);

        return ray.init(ray_origin, ray_direction);
    }

    pub fn sample_square() vec3 {
        return vec3.init(helper.random_double() - 0.5, helper.random_double() - 0.5, 0);
    }

    fn ray_color(self: *camera, r: ray, depth: u16, world: hittable_list) color.color {
        if (depth <= 0) {
            return color.color.zero();
        }
        var rec: hit_record = undefined;

        if (world.hit(r, interval.init(0.001, helper.infinity), &rec)) {
            const direction: vec3 = rec.normal.add(vec3.random_unit_vector());
            return self.ray_color(ray.init(rec.p, direction), depth - 1, world).scale(0.5);
        }

        const unit_direction: vec3 = r.direction.unit_vector();
        const a: f64 = 0.5 * (unit_direction.y + 1.0);
        return color.color.init(1.0, 1.0, 1.0).scale(1.0 - a).add(color.color.init(0.5, 0.7, 1.0).scale(a));
    }
};
