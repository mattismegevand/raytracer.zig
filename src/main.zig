const std = @import("std");
const point3 = @import("vec3.zig").point3;
const hittable = @import("hittable.zig").hittable;
const hittable_list = @import("hittable_list.zig").hittable_list;
const sphere = @import("sphere.zig").sphere;
const camera = @import("camera.zig").camera;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var world = hittable_list{ .objects = std.ArrayList(hittable).init(allocator) };
    defer world.objects.deinit();

    try world.objects.append(hittable{ .sphere = sphere.init(point3.init(0, 0, -1), 0.5) });
    try world.objects.append(hittable{ .sphere = sphere.init(point3.init(0, -100.5, -1), 100) });

    var cam: camera = undefined;
    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 400;

    try cam.render(world);
}
