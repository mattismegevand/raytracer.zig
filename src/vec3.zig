const std = @import("std");
const helper = @import("helper.zig");

pub const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn zero() Vec3 {
        return .{ .x = 0, .y = 0, .z = 0 };
    }

    pub fn init(x: f64, y: f64, z: f64) Vec3 {
        return .{ .x = x, .y = y, .z = z };
    }

    pub fn neg(self: Vec3) Vec3 {
        return .{ .x = -self.x, .y = -self.y, .z = -self.z };
    }

    pub fn add(self: Vec3, t: Vec3) Vec3 {
        return .{ .x = self.x + t.x, .y = self.y + t.y, .z = self.z + t.z };
    }

    pub fn sub(self: Vec3, v: Vec3) Vec3 {
        return self.add(v.neg());
    }

    pub fn scale(self: Vec3, t: f64) Vec3 {
        return .{ .x = self.x * t, .y = self.y * t, .z = self.z * t };
    }

    pub fn mul(self: Vec3, v: Vec3) Vec3 {
        return .{ .x = self.x * v.x, .y = self.y * v.y, .z = self.z * v.z };
    }

    pub fn dot(self: Vec3, v: Vec3) f64 {
        return self.x * v.x + self.y * v.y + self.z * v.z;
    }

    pub fn cross(self: Vec3, v: Vec3) Vec3 {
        return .{
            .x = self.y * v.z - self.z * v.y,
            .y = self.z * v.x - self.x * v.z,
            .z = self.x * v.y - self.y * v.x,
        };
    }

    pub fn length(self: Vec3) f64 {
        return @sqrt(self.lengthSquared());
    }

    pub fn lengthSquared(self: Vec3) f64 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn nearZero(self: Vec3) bool {
        const s = 1e-8;
        return (@abs(self.x) < s) and (@abs(self.y) < s) and (@abs(self.z) < s);
    }

    pub fn unitVector(self: Vec3) Vec3 {
        return self.scale(1.0 / self.length());
    }

    pub fn random() Vec3 {
        return .{ .x = helper.randomDouble(), .y = helper.randomDouble(), .z = helper.randomDouble() };
    }

    pub fn randomRange(min: f64, max: f64) Vec3 {
        return .{
            .x = helper.randomDoubleRange(min, max),
            .y = helper.randomDoubleRange(min, max),
            .z = helper.randomDoubleRange(min, max),
        };
    }

    pub fn randomInUnitSphere() Vec3 {
        while (true) {
            const p = Vec3.randomRange(-1, 1);
            if (p.lengthSquared() < 1) {
                return p;
            }
        }
    }

    pub fn randomUnitVector() Vec3 {
        return randomInUnitSphere().unitVector();
    }

    pub fn randomOnHemisphere(normal: Vec3) Vec3 {
        const on_unit_sphere = randomUnitVector();
        if (on_unit_sphere.dot(normal) > 0.0) {
            return on_unit_sphere;
        } else {
            return on_unit_sphere.neg();
        }
    }

    pub fn reflect(v: Vec3, n: Vec3) Vec3 {
        return v.sub(n.scale(2 * v.dot(n)));
    }

    pub fn refract(uv: Vec3, n: Vec3, etai_over_etat: f64) Vec3 {
        const cos_theta = @min(uv.neg().dot(n), 1.0);
        const r_out_prep = uv.add(n.scale(cos_theta)).scale(etai_over_etat);
        const r_out_parallel = n.scale(-@sqrt(@abs(1.0 - r_out_prep.lengthSquared())));
        return r_out_prep.add(r_out_parallel);
    }

    pub fn randomInUnitDisk() Vec3 {
        while (true) {
            const p = Vec3.init(helper.randomDoubleRange(-1, 1), helper.randomDoubleRange(-1, 1), 0);
            if (p.lengthSquared() < 1) {
                return p;
            }
        }
    }
};

pub const Point3 = Vec3;
