const std = @import("std");
const hit_record = @import("hittable.zig").hit_record;
const vec3 = @import("vec3.zig").vec3;
const point3 = @import("vec3.zig").point3;
const ray = @import("ray.zig").ray;

pub const sphere = struct {
    center: point3,
    radius: f64,

    pub fn init(center: point3, radius: f64) sphere {
        return sphere{ .center = center, .radius = radius };
    }

    pub fn hit(self: sphere, r: ray, ray_tmin: f64, ray_tmax: f64, rec: *hit_record) bool {
        const oc: vec3 = self.center.sub(r.origin);
        const a: f64 = r.direction.length_squared();
        const h: f64 = r.direction.dot(oc);
        const c: f64 = oc.length_squared() - self.radius * self.radius;

        const discriminant: f64 = h * h - a * c;
        if (discriminant < 0) {
            return false;
        }

        const sqrtd: f64 = @sqrt(discriminant);

        var root: f64 = (h - sqrtd) / a;
        if (root <= ray_tmin or ray_tmax <= root) {
            root = (h + sqrtd) / a;
            if (root <= ray_tmin or ray_tmax <= root) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal: vec3 = rec.p.sub(self.center).scale(1.0 / self.radius);
        rec.set_face_normal(r, outward_normal);

        return true;
    }
};
