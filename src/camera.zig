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
const material = @import("material.zig").material;

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
    vfov: f64,
    lookfrom: point3,
    lookat: point3,
    vup: vec3,
    u: vec3,
    v: vec3,
    w: vec3,
    defocus_angle: f64,
    focus_dist: f64,
    defocus_disk_u: vec3,
    defocus_disk_v: vec3,

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
                    var r: ray = self.get_ray(i, j);
                    pixel_color = pixel_color.add(ray_color(&r, self.max_depth, world));
                }
                try color.write_color(stdout, pixel_color.scale(self.pixel_samples_scale));
            }
        }
        std.debug.print("Done.\n", .{});

        try bw.flush();
    }

    pub fn init(self: *camera) !void {
        try helper.random_init();

        self.image_height = @as(u16, @intFromFloat(@as(f64, @floatFromInt(self.image_width)) / self.aspect_ratio));
        self.image_height = if (self.image_height < 1) 1 else self.image_height;

        self.pixel_samples_scale = 1.0 / @as(f64, @floatFromInt(self.samples_per_pixel));

        self.center = self.lookfrom;

        const theta: f64 = helper.degrees_to_radians(self.vfov);
        const h: f64 = @tan(theta / 2);
        const viewport_height: f64 = 2 * h * self.focus_dist;
        const viewport_width: f64 = viewport_height * (@as(f64, @floatFromInt(self.image_width)) / @as(f64, @floatFromInt(self.image_height)));

        self.w = self.lookfrom.sub(self.lookat).unit_vector();
        self.u = self.vup.cross(self.w).unit_vector();
        self.v = self.w.cross(self.u);

        const viewport_u: vec3 = self.u.scale(viewport_width);
        const viewport_v: vec3 = self.v.neg().scale(viewport_height);

        self.pixel_delta_u = viewport_u.scale(1.0 / @as(f64, @floatFromInt(self.image_width)));
        self.pixel_delta_v = viewport_v.scale(1.0 / @as(f64, @floatFromInt(self.image_height)));

        const viewport_upper_left = self.center.sub(self.w.scale(self.focus_dist)).sub(viewport_u.scale(0.5)).sub(viewport_v.scale(0.5));
        self.pixel00_loc = viewport_upper_left.add(self.pixel_delta_u.add(self.pixel_delta_v).scale(0.5));

        const defocus_radius: f64 = self.focus_dist * @tan(helper.degrees_to_radians(self.defocus_angle / 2));
        self.defocus_disk_u = self.u.scale(defocus_radius);
        self.defocus_disk_v = self.v.scale(defocus_radius);
    }

    pub fn get_ray(self: *camera, i: u16, j: u16) ray {
        const offset: vec3 = sample_square();
        const pixel_sample: point3 = self.pixel00_loc.add(self.pixel_delta_u.scale(@as(f64, @floatFromInt(i)) + offset.x)).add(self.pixel_delta_v.scale(@as(f64, @floatFromInt(j)) + offset.y));

        const ray_origin: vec3 = if (self.defocus_angle <= 0) self.center else self.defocus_disk_sample();
        const ray_direction: vec3 = pixel_sample.sub(ray_origin);

        return ray.init(ray_origin, ray_direction);
    }

    pub fn sample_square() vec3 {
        return vec3.init(helper.random_double() - 0.5, helper.random_double() - 0.5, 0);
    }

    pub fn defocus_disk_sample(self: *camera) vec3 {
        const p: vec3 = vec3.random_in_unit_disk();
        return self.center.add(self.defocus_disk_u.scale(p.x)).add(self.defocus_disk_v.scale(p.y));
    }

    fn ray_color(r: *ray, depth: u16, world: hittable_list) color.color {
        if (depth <= 0) {
            return color.color.zero();
        }
        var rec: hit_record = undefined;

        if (world.hit(r.*, interval.init(0.001, helper.infinity), &rec)) {
            var scattered: ray = undefined;
            var attenuation: color.color = undefined;
            if (rec.mat.scatter(r, &rec, &attenuation, &scattered)) {
                return attenuation.mul(ray_color(&scattered, depth - 1, world));
            }
            return color.color.zero();
        }

        const unit_direction: vec3 = r.direction.unit_vector();
        const a: f64 = 0.5 * (unit_direction.y + 1.0);
        return color.color.init(1.0, 1.0, 1.0).scale(1.0 - a).add(color.color.init(0.5, 0.7, 1.0).scale(a));
    }
};
