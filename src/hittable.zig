const std = @import("std");
const vec3 = @import("vec3.zig").vec3;
const point3 = @import("vec3.zig").point3;

pub const hit_record = struct {
    p: point3,
    normal: vec3,
    t: f64,
    front_face: bool,

    pub fn set_face_normal(r: ray, outward_normal: vec3) void {
        front_face = r.direction.dot(outward_normal) < 0;
        normal = if (front_face) outward_normal else -outward_normal;
    }
};
