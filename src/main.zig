const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const Point3 = @import("vec3.zig").Point3;
const Hittable = @import("hittable.zig").Hittable;
const HittableList = @import("hittable_list.zig").HittableList;
const Sphere = @import("sphere.zig").Sphere;
const Camera = @import("camera.zig").Camera;
const color = @import("color.zig");
const Color = color.Color;
const material = @import("material.zig");
const Material = material.Material;
const Lambertian = material.Lambertian;
const Metal = material.Metal;
const Dielectric = material.Dielectric;
const helper = @import("helper.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var world = HittableList{ .objects = std.ArrayList(Hittable).init(allocator) };
    defer world.objects.deinit();

    const ground_material = Material{ .lambertian = Lambertian.init(Color.init(0.5, 0.5, 0.5)) };
    try world.objects.append(Hittable{ .sphere = Sphere.init(Point3.init(0, -1000, 0), 1000, ground_material) });

    try helper.randomInit();

    var a: i16 = -11;
    while (a < 11) : (a += 1) {
        var b: i16 = -11;
        while (b < 11) : (b += 1) {
            const choose_mat = helper.randomDouble();
            const center = Point3.init(@as(f64, @floatFromInt(a)) + 0.9 * helper.randomDouble(), 0.2, @as(f64, @floatFromInt(b)) + 0.9 * helper.randomDouble());

            if (center.sub(Point3.init(4, 0.2, 0)).length() > 0.9) {
                var sphere_material: Material = undefined;
                if (choose_mat < 0.8) {
                    const albedo = Color.random().mul(Color.random());
                    sphere_material = Material{ .lambertian = Lambertian.init(albedo) };
                } else if (choose_mat < 0.95) {
                    const albedo = Color.randomRange(0.5, 1);
                    const fuzz = helper.randomDoubleRange(0, 0.5);
                    sphere_material = Material{ .metal = Metal.init(albedo, fuzz) };
                } else {
                    sphere_material = Material{ .dielectric = Dielectric.init(1.5) };
                }
                try world.objects.append(Hittable{ .sphere = Sphere.init(center, 0.2, sphere_material) });
            }
        }
    }

    const material1 = Material{ .dielectric = Dielectric.init(1.5) };
    try world.objects.append(Hittable{ .sphere = Sphere.init(Point3.init(0, 1, 0), 1.0, material1) });

    const material2 = Material{ .lambertian = Lambertian.init(Color.init(0.4, 0.2, 0.1)) };
    try world.objects.append(Hittable{ .sphere = Sphere.init(Point3.init(-4, 1, 0), 1.0, material2) });

    const material3 = Material{ .metal = Metal.init(Color.init(0.7, 0.6, 0.5), 0.0) };
    try world.objects.append(Hittable{ .sphere = Sphere.init(Point3.init(4, 1, 0), 1.0, material3) });

    var cam: Camera = undefined;

    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 1200;
    cam.samples_per_pixel = 500;
    cam.max_depth = 50;

    cam.vfov = 20;
    cam.lookfrom = Point3.init(13, 2, 3);
    cam.lookat = Point3.init(0, 0, 0);
    cam.vup = Vec3.init(0, 1, 0);

    cam.defocus_angle = 0.6;
    cam.focus_dist = 10.0;

    try cam.render(world);
}
