const std = @import("std");
const HitRecord = @import("hittable.zig").HitRecord;
const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;
const Ray = @import("ray.zig").Ray;
const Interval = @import("interval.zig").Interval;
const Material = @import("material.zig").Material;

pub const Sphere = struct {
    center: Point3,
    radius: f64,
    mat: Material,

    pub fn init(center: Point3, radius: f64, mat: Material) Sphere {
        return .{ .center = center, .radius = radius, .mat = mat };
    }

    pub fn hit(self: Sphere, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
        const oc = self.center.sub(r.origin);
        const a = r.direction.lengthSquared();
        const h = r.direction.dot(oc);
        const c = oc.lengthSquared() - self.radius * self.radius;

        const discriminant = h * h - a * c;
        if (discriminant < 0) {
            return false;
        }

        const sqrtd = @sqrt(discriminant);

        var root = (h - sqrtd) / a;
        if (root <= ray_t.min or ray_t.max <= root) {
            root = (h + sqrtd) / a;
            if (root <= ray_t.min or ray_t.max <= root) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal = rec.p.sub(self.center).scale(1.0 / self.radius);
        rec.setFaceNormal(r, outward_normal);
        rec.mat = self.mat;

        return true;
    }
};
