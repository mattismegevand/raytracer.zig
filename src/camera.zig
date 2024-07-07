const std = @import("std");
const color = @import("color.zig");
const Color = color.Color;
const Ray = @import("ray.zig").Ray;
const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;
const hittable = @import("hittable.zig");
const HitRecord = hittable.HitRecord;
const Hittable = hittable.Hittable;
const HittableList = @import("hittable_list.zig").HittableList;
const Sphere = @import("sphere.zig").Sphere;
const helper = @import("helper.zig");
const Interval = @import("interval.zig").Interval;
const Material = @import("material.zig").Material;

pub const Camera = struct {
    aspect_ratio: f64,
    image_width: u16,
    image_height: u16,
    center: Point3,
    pixel00_loc: Point3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,
    samples_per_pixel: u16,
    pixel_samples_scale: f64,
    max_depth: u16,
    vfov: f64,
    lookfrom: Point3,
    lookat: Point3,
    vup: Vec3,
    u: Vec3,
    v: Vec3,
    w: Vec3,
    defocus_angle: f64,
    focus_dist: f64,
    defocus_disk_u: Vec3,
    defocus_disk_v: Vec3,

    pub fn render(self: *Camera, world: HittableList) !void {
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
                var pixel_color = Color.zero();
                var sample: u16 = 0;
                while (sample < self.samples_per_pixel) : (sample += 1) {
                    var r = self.get_ray(i, j);
                    pixel_color = pixel_color.add(ray_color(&r, self.max_depth, world));
                }
                try color.writeColor(stdout, pixel_color.scale(self.pixel_samples_scale));
            }
        }
        std.debug.print("Done.\n", .{});

        try bw.flush();
    }

    pub fn init(self: *Camera) !void {
        try helper.randomInit();

        self.image_height = @as(u16, @intFromFloat(@as(f64, @floatFromInt(self.image_width)) / self.aspect_ratio));
        self.image_height = if (self.image_height < 1) 1 else self.image_height;

        self.pixel_samples_scale = 1.0 / @as(f64, @floatFromInt(self.samples_per_pixel));

        self.center = self.lookfrom;

        const theta = helper.degreesToRadians(self.vfov);
        const h = @tan(theta / 2);
        const viewport_height = 2 * h * self.focus_dist;
        const viewport_width = viewport_height * (@as(f64, @floatFromInt(self.image_width)) / @as(f64, @floatFromInt(self.image_height)));

        self.w = self.lookfrom.sub(self.lookat).unitVector();
        self.u = self.vup.cross(self.w).unitVector();
        self.v = self.w.cross(self.u);

        const viewport_u = self.u.scale(viewport_width);
        const viewport_v = self.v.neg().scale(viewport_height);

        self.pixel_delta_u = viewport_u.scale(1.0 / @as(f64, @floatFromInt(self.image_width)));
        self.pixel_delta_v = viewport_v.scale(1.0 / @as(f64, @floatFromInt(self.image_height)));

        const viewport_upper_left = self.center.sub(self.w.scale(self.focus_dist)).sub(viewport_u.scale(0.5)).sub(viewport_v.scale(0.5));
        self.pixel00_loc = viewport_upper_left.add(self.pixel_delta_u.add(self.pixel_delta_v).scale(0.5));

        const defocus_radius = self.focus_dist * @tan(helper.degreesToRadians(self.defocus_angle / 2));
        self.defocus_disk_u = self.u.scale(defocus_radius);
        self.defocus_disk_v = self.v.scale(defocus_radius);
    }

    pub fn get_ray(self: *Camera, i: u16, j: u16) Ray {
        const offset = sample_square();
        const pixel_sample = self.pixel00_loc.add(self.pixel_delta_u.scale(@as(f64, @floatFromInt(i)) + offset.x)).add(self.pixel_delta_v.scale(@as(f64, @floatFromInt(j)) + offset.y));

        const ray_origin = if (self.defocus_angle <= 0) self.center else self.defocus_disk_sample();
        const ray_direction = pixel_sample.sub(ray_origin);

        return Ray.init(ray_origin, ray_direction);
    }

    pub fn sample_square() Vec3 {
        return Vec3.init(helper.randomDouble() - 0.5, helper.randomDouble() - 0.5, 0);
    }

    pub fn defocus_disk_sample(self: *Camera) Vec3 {
        const p = Vec3.randomInUnitDisk();
        return self.center.add(self.defocus_disk_u.scale(p.x)).add(self.defocus_disk_v.scale(p.y));
    }

    fn ray_color(r: *Ray, depth: u16, world: HittableList) Color {
        if (depth <= 0) {
            return Color.zero();
        }
        var rec: HitRecord = undefined;

        if (world.hit(r.*, Interval.init(0.001, helper.infinity), &rec)) {
            var scattered: Ray = undefined;
            var attenuation: Color = undefined;
            if (rec.mat.scatter(r, &rec, &attenuation, &scattered)) {
                return attenuation.mul(ray_color(&scattered, depth - 1, world));
            }
            return Color.zero();
        }

        const unit_direction = r.direction.unitVector();
        const a = 0.5 * (unit_direction.y + 1.0);
        return Color.init(1.0, 1.0, 1.0).scale(1.0 - a).add(Color.init(0.5, 0.7, 1.0).scale(a));
    }
};
