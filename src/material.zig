const std = @import("std");
const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;
const Ray = @import("ray.zig").Ray;
const Sphere = @import("sphere.zig").Sphere;
const Interval = @import("interval.zig").Interval;
const HitRecord = @import("hittable.zig").HitRecord;
const Color = @import("color.zig").Color;
const helper = @import("helper.zig");

pub const Material = union(enum) {
    lambertian: Lambertian,
    metal: Metal,
    dielectric: Dielectric,

    pub fn scatter(self: Material, r_in: *Ray, rec: *HitRecord, attenuation: *Color, scattered: *Ray) bool {
        return switch (self) {
            .lambertian => |l| l.scatter(r_in, rec, attenuation, scattered),
            .metal => |m| m.scatter(r_in, rec, attenuation, scattered),
            .dielectric => |d| d.scatter(r_in, rec, attenuation, scattered),
        };
    }
};

pub const Lambertian = struct {
    albedo: Color,

    pub fn init(albedo: Color) Lambertian {
        return .{ .albedo = albedo };
    }

    pub fn scatter(self: Lambertian, _: *Ray, rec: *HitRecord, attenuation: *Color, scattered: *Ray) bool {
        var scatter_direction = rec.normal.add(Vec3.randomUnitVector());

        if (scatter_direction.nearZero()) {
            scatter_direction = rec.normal;
        }

        scattered.* = Ray.init(rec.p, scatter_direction);
        attenuation.* = self.albedo;
        return true;
    }
};

pub const Metal = struct {
    albedo: Color,
    fuzz: f64,

    pub fn init(albedo: Color, fuzz: f64) Metal {
        return .{ .albedo = albedo, .fuzz = if (fuzz < 1.0) fuzz else 1.0 };
    }

    pub fn scatter(self: Metal, r_in: *Ray, rec: *HitRecord, attenuation: *Color, scattered: *Ray) bool {
        var reflected = Vec3.reflect(r_in.direction, rec.normal);
        reflected = reflected.unitVector().add(Vec3.randomUnitVector().scale(self.fuzz));
        scattered.* = Ray.init(rec.p, reflected);
        attenuation.* = self.albedo;
        return (scattered.direction.dot(rec.normal) > 0.0);
    }
};

pub const Dielectric = struct {
    refraction_index: f64,

    pub fn init(refraction_index: f64) Dielectric {
        return .{ .refraction_index = refraction_index };
    }

    pub fn scatter(self: Dielectric, r_in: *Ray, rec: *HitRecord, attenuation: *Color, scattered: *Ray) bool {
        attenuation.* = Color.init(1.0, 1.0, 1.0);
        const ri = if (rec.front_face) (1.0 / self.refraction_index) else self.refraction_index;

        const unit_direction = Vec3.unitVector(r_in.direction);
        const cos_theta = @min(unit_direction.neg().dot(rec.normal), 1.0);
        const sin_theta = @sqrt(1.0 - cos_theta * cos_theta);

        const cannot_refract = (ri * sin_theta) > 1.0;
        var direction: Vec3 = undefined;

        if (cannot_refract) { // or reflectance(cos_theta, ri) > helper.random_double()) {
            direction = Vec3.reflect(unit_direction, rec.normal);
        } else {
            direction = Vec3.refract(unit_direction, rec.normal, ri);
        }

        scattered.* = Ray.init(rec.p, direction);
        return true;
    }

    pub fn reflectance(cosine: f64, refraction_index: f64) f64 {
        var r0 = (1 - refraction_index) / (1 + refraction_index);
        r0 = r0 * r0;
        return r0 + (1 - r0) * std.math.pow(f64, (1 - cosine), 5);
    }
};
