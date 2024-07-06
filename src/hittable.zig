const std = @import("std");
const vec3 = @import("vec3.zig").vec3;
const point3 = @import("vec3.zig").point3;
const ray = @import("ray.zig").ray;
const sphere = @import("sphere.zig").sphere;
const interval = @import("interval.zig").interval;

pub const hit_record = struct {
    p: point3,
    normal: vec3,
    t: f64,
    front_face: bool,

    pub fn set_face_normal(self: *hit_record, r: ray, outward_normal: vec3) void {
        self.front_face = r.direction.dot(outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else outward_normal.neg();
    }
};

pub const hittable = union(enum) {
    sphere: sphere,

    pub fn hit(self: hittable, r: ray, ray_t: interval, rec: *hit_record) bool {
        return switch (self) {
            .sphere => |s| s.hit(r, ray_t, rec),
        };
    }
};
