const std = @import("std");
const vec3 = @import("vec3.zig").vec3;
const point3 = @import("vec3.zig").point3;
const ray = @import("ray.zig").ray;
const sphere = @import("sphere.zig").sphere;
const interval = @import("interval.zig").interval;
const hit_record = @import("hittable.zig").hit_record;
const color = @import("color.zig").color;
const helper = @import("helper.zig");

pub const material = union(enum) {
    lambertian: lambertian,
    metal: metal,
    dielectric: dielectric,

    pub fn scatter(self: material, r_in: *ray, rec: *hit_record, attenuation: *color, scattered: *ray) bool {
        return switch (self) {
            .lambertian => |l| l.scatter(r_in, rec, attenuation, scattered),
            .metal => |m| m.scatter(r_in, rec, attenuation, scattered),
            .dielectric => |d| d.scatter(r_in, rec, attenuation, scattered),
        };
    }
};

pub const lambertian = struct {
    albedo: color,

    pub fn init(albedo: color) lambertian {
        return lambertian{ .albedo = albedo };
    }

    pub fn scatter(self: lambertian, _: *ray, rec: *hit_record, attenuation: *color, scattered: *ray) bool {
        var scatter_direction: vec3 = rec.normal.add(vec3.random_unit_vector());

        if (scatter_direction.near_zero()) {
            scatter_direction = rec.normal;
        }

        scattered.* = ray.init(rec.p, scatter_direction);
        attenuation.* = self.albedo;
        return true;
    }
};

pub const metal = struct {
    albedo: color,
    fuzz: f64,

    pub fn init(albedo: color, fuzz: f64) metal {
        return metal{ .albedo = albedo, .fuzz = if (fuzz < 1.0) fuzz else 1.0 };
    }

    pub fn scatter(self: metal, r_in: *ray, rec: *hit_record, attenuation: *color, scattered: *ray) bool {
        var reflected: vec3 = vec3.reflect(r_in.direction, rec.normal);
        reflected = reflected.unit_vector().add(vec3.random_unit_vector().scale(self.fuzz));
        scattered.* = ray.init(rec.p, reflected);
        attenuation.* = self.albedo;
        return (scattered.direction.dot(rec.normal) > 0.0);
    }
};

pub const dielectric = struct {
    refraction_index: f64,

    pub fn init(refraction_index: f64) dielectric {
        return dielectric{ .refraction_index = refraction_index };
    }

    pub fn scatter(self: dielectric, r_in: *ray, rec: *hit_record, attenuation: *color, scattered: *ray) bool {
        attenuation.* = color.init(1.0, 1.0, 1.0);
        const ri: f64 = if (rec.front_face) (1.0 / self.refraction_index) else self.refraction_index;

        const unit_direction: vec3 = vec3.unit_vector(r_in.direction);
        const cos_theta: f64 = @min(unit_direction.neg().dot(rec.normal), 1.0);
        const sin_theta: f64 = @sqrt(1.0 - cos_theta * cos_theta);

        const cannot_refract: bool = (ri * sin_theta) > 1.0;
        var direction: vec3 = undefined;

        if (cannot_refract) { // or reflectance(cos_theta, ri) > helper.random_double()) {
            direction = vec3.reflect(unit_direction, rec.normal);
        } else {
            direction = vec3.refract(unit_direction, rec.normal, ri);
        }

        // const refracted: vec3 = vec3.refract(unit_direction, rec.normal, ri);

        scattered.* = ray.init(rec.p, direction);
        return true;
    }

    pub fn reflectance(cosine: f64, refraction_index: f64) f64 {
        var r0: f64 = (1 - refraction_index) / (1 + refraction_index);
        r0 = r0 * r0;
        return r0 + (1 - r0) * std.math.pow(f64, (1 - cosine), 5);
    }
};
