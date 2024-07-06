const std = @import("std");
const vec3 = @import("vec3.zig").vec3;
const point3 = @import("vec3.zig").point3;
const ray = @import("ray.zig").ray;
const hit_record = @import("hittable.zig").hit_record;
const hittable = @import("hittable.zig").hittable;

pub const hittable_list = struct {
    objects: std.ArrayList(hittable),

    pub fn hit(self: hittable_list, r: ray, ray_tmin: f64, ray_tmax: f64, rec: *hit_record) bool {
        var temp_rec: hit_record = undefined;
        var hit_anything: bool = false;
        var closest_so_far: f64 = ray_tmax;

        for (self.objects.items) |object| {
            if (object.hit(r, ray_tmin, closest_so_far, &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }

        return hit_anything;
    }
};
