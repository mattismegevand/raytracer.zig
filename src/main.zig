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

    const material_ground: material.material = material.material{ .lambertian = material.lambertian.init(color.color.init(0.8, 0.8, 0.0)) };
    const material_center: material.material = material.material{ .lambertian = material.lambertian.init(color.color.init(0.1, 0.2, 0.5)) };
    const material_left: material.material = material.material{ .dielectric = material.dielectric.init(1.50) };
    const material_bubble: material.material = material.material{ .dielectric = material.dielectric.init(1.00 / 1.50) };
    const material_right: material.material = material.material{ .metal = material.metal.init(color.color.init(0.8, 0.6, 0.2), 1.0) };

    try world.objects.append(hittable{ .sphere = sphere.init(point3.init(0.0, -100.5, -1.0), 100.0, material_ground) });
    try world.objects.append(hittable{ .sphere = sphere.init(point3.init(0.0, 0.0, -1.2), 0.5, material_center) });
    try world.objects.append(hittable{ .sphere = sphere.init(point3.init(-1.0, 0.0, -1.0), 0.5, material_left) });
    try world.objects.append(hittable{ .sphere = sphere.init(point3.init(-1.0, 0.0, -1.0), 0.4, material_bubble) });
    try world.objects.append(hittable{ .sphere = sphere.init(point3.init(1.0, 0.0, -1.0), 0.5, material_right) });

    var cam: camera = undefined;

    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 400;
    cam.samples_per_pixel = 100;
    cam.max_depth = 50;

    cam.vfov = 20;
    cam.lookfrom = point3.init(-2, 2, 1);
    cam.lookat = point3.init(0, 0, -1);
    cam.vup = vec3.init(0, 1, 0);

    cam.defocus_angle = 10.0;
    cam.focus_dist = 3.4;

    try cam.render(world);
}
