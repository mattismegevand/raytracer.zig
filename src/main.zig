const std = @import("std");
const vec3 = @import("vec3.zig").vec3;
const point3 = @import("vec3.zig").point3;
const hittable = @import("hittable.zig").hittable;
const hittable_list = @import("hittable_list.zig").hittable_list;
const sphere = @import("sphere.zig").sphere;
const camera = @import("camera.zig").camera;
const color = @import("color.zig");
const material = @import("material.zig");
const helper = @import("helper.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var world = hittable_list{ .objects = std.ArrayList(hittable).init(allocator) };
    defer world.objects.deinit();

    const ground_material: material.material = material.material{ .lambertian = material.lambertian.init(color.color.init(0.5, 0.5, 0.5)) };
    try world.objects.append(hittable{ .sphere = sphere.init(point3.init(0, -1000, 0), 1000, ground_material) });

    try helper.random_init();

    var a: i16 = -11;
    while (a < 11) : (a += 1) {
        var b: i16 = -11;
        while (b < 11) : (b += 1) {
            const choose_mat: f64 = helper.random_double();
            const center: point3 = point3.init(@as(f64, @floatFromInt(a)) + 0.9 * helper.random_double(), 0.2, @as(f64, @floatFromInt(b)) + 0.9 * helper.random_double());

            if (center.sub(point3.init(4, 0.2, 0)).length() > 0.9) {
                var sphere_material: material.material = undefined;
                if (choose_mat < 0.8) {
                    const albedo: color.color = color.color.random().mul(color.color.random());
                    sphere_material = material.material{ .lambertian = material.lambertian.init(albedo) };
                } else if (choose_mat < 0.95) {
                    const albedo: color.color = color.color.random_range(0.5, 1);
                    const fuzz: f64 = helper.random_double_range(0, 0.5);
                    sphere_material = material.material{ .metal = material.metal.init(albedo, fuzz) };
                } else {
                    sphere_material = material.material{ .dielectric = material.dielectric.init(1.5) };
                }
                try world.objects.append(hittable{ .sphere = sphere.init(center, 0.2, sphere_material) });
            }
        }
    }

    const material1: material.material = material.material{ .dielectric = material.dielectric.init(1.5) };
    try world.objects.append(hittable{ .sphere = sphere.init(point3.init(0, 1, 0), 1.0, material1) });

    const material2: material.material = material.material{ .lambertian = material.lambertian.init(color.color.init(0.4, 0.2, 0.1)) };
    try world.objects.append(hittable{ .sphere = sphere.init(point3.init(-4, 1, 0), 1.0, material2) });

    const material3: material.material = material.material{ .metal = material.metal.init(color.color.init(0.7, 0.6, 0.5), 0.0) };
    try world.objects.append(hittable{ .sphere = sphere.init(point3.init(4, 1, 0), 1.0, material3) });

    var cam: camera = undefined;

    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 1200;
    cam.samples_per_pixel = 500;
    cam.max_depth = 50;

    cam.vfov = 20;
    cam.lookfrom = point3.init(13, 2, 3);
    cam.lookat = point3.init(0, 0, 0);
    cam.vup = vec3.init(0, 1, 0);

    cam.defocus_angle = 0.6;
    cam.focus_dist = 10.0;

    try cam.render(world);
}
