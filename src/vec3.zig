const std = @import("std");
const helper = @import("helper.zig");

pub const vec3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn zero() vec3 {
        return vec3{ .x = 0, .y = 0, .z = 0 };
    }

    pub fn init(x: f64, y: f64, z: f64) vec3 {
        return vec3{ .x = x, .y = y, .z = z };
    }

    pub fn neg(self: vec3) vec3 {
        return vec3{ .x = -self.x, .y = -self.y, .z = -self.z };
    }

    pub fn add(self: vec3, t: vec3) vec3 {
        return vec3{ .x = self.x + t.x, .y = self.y + t.y, .z = self.z + t.z };
    }

    pub fn sub(u: vec3, v: vec3) vec3 {
        return u.add(v.neg());
    }

    pub fn scale(self: vec3, t: f64) vec3 {
        return vec3{ .x = self.x * t, .y = self.y * t, .z = self.z * t };
    }

    pub fn mul(self: vec3, v: vec3) vec3 {
        return vec3{ .x = self.x * v.x, .y = self.y * v.y, .z = self.z * v.z };
    }

    pub fn dot(self: vec3, v: vec3) f64 {
        return self.x * v.x + self.y * v.y + self.z * v.z;
    }

    pub fn cross(self: vec3, v: vec3) vec3 {
        return vec3{
            .x = self.y * v.z - self.z * v.y,
            .y = self.z * v.x - self.x * v.z,
            .z = self.x * v.y - self.y * v.x,
        };
    }

    pub fn length(self: vec3) f64 {
        return @sqrt(self.length_squared());
    }

    pub fn length_squared(self: vec3) f64 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn unit_vector(self: vec3) vec3 {
        return self.scale(1.0 / self.length());
    }

    pub fn random() vec3 {
        return vec3{ .x = helper.random_double(), .y = helper.random_double(), .z = helper.random_double() };
    }

    pub fn random_range(min: f64, max: f64) vec3 {
        return vec3{ .x = helper.random_double_range(min, max), .y = helper.random_double_range(min, max), .z = helper.random_double_range(min, max) };
    }

    pub fn random_in_unit_sphere() vec3 {
        while (true) {
            const p: vec3 = vec3.random_range(-1, 1);
            if (p.length_squared() < 1) {
                return p;
            }
        }
    }

    pub fn random_unit_vector() vec3 {
        return random_in_unit_sphere().unit_vector();
    }

    pub fn random_on_hemisphere(normal: vec3) vec3 {
        const on_unit_sphere: vec3 = random_unit_vector();
        if (on_unit_sphere.dot(normal) > 0.0) {
            return on_unit_sphere;
        } else {
            return on_unit_sphere.neg();
        }
    }
};

pub const point3 = vec3;
