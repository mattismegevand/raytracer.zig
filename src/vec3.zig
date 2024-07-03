const std = @import("std");

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

    pub fn scale(self: vec3, t: f64) !void {
        self.x *= t;
        self.y *= t;
        self.z *= t;
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

    pub fn unit_vector(v: vec3) vec3 {
        return v.div(v.length());
    }
};

pub const point3 = vec3;
