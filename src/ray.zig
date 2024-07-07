const std = @import("std");
const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;

pub const Ray = struct {
    origin: Point3,
    direction: Vec3,

    pub fn init(origin: Point3, direction: Vec3) Ray {
        return .{ .origin = origin, .direction = direction };
    }

    pub fn at(self: Ray, t: f64) Vec3 {
        return self.origin.add(self.direction.scale(t));
    }
};
