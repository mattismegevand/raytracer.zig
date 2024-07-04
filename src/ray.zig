const std = @import("std");
const vec3 = @import("vec3.zig");

pub const ray = struct {
    origin: vec3.point3,
    direction: vec3.vec3,

    pub fn init(origin: vec3.point3, direction: vec3.vec3) ray {
        return ray{ .origin = origin, .direction = direction };
    }

    pub fn at(self: ray, t: f64) vec3.vec3 {
        return self.origin.add(self.direction.scale(t));
    }
};
