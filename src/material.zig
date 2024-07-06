const std = @import("std");
const vec3 = @import("vec3.zig").vec3;
const point3 = @import("vec3.zig").point3;
const ray = @import("ray.zig").ray;
const sphere = @import("sphere.zig").sphere;
const interval = @import("interval.zig").interval;
const hit_record = @import("hittable.zig").hit_record;
const color = @import("color.zig").color;
const helper = @import("helper.zig").helper;

pub const material = union(enum) {
    lambertian: lambertian,
    metal: metal,

    pub fn scatter(self: material, r_in: *ray, rec: *hit_record, attenuation: *color, scattered: *ray) bool {
        return switch (self) {
            .lambertian => |l| l.scatter(r_in, rec, attenuation, scattered),
            .metal => |m| m.scatter(r_in, rec, attenuation, scattered),
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
