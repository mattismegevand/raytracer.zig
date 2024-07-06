const std = @import("std");
const helper = @import("helper.zig");
const vec3 = @import("vec3.zig").vec3;
const point3 = @import("vec3.zig").point3;
const ray = @import("ray.zig").ray;
const sphere = @import("sphere.zig").sphere;

pub const interval = struct {
    min: f64,
    max: f64,

    pub fn default() interval {
        return interval{ .min = helper.infinity, .max = -helper.infinity };
    }

    pub fn init(min: f64, max: f64) interval {
        return interval{ .min = min, .max = max };
    }

    pub fn size(self: interval) f64 {
        return self.max - self.min;
    }

    pub fn contains(self: interval, x: f64) bool {
        return self.min <= x and x <= self.max;
    }

    pub fn surrounds(self: interval, x: f64) bool {
        return self.min < x and x < self.max;
    }

    pub fn clamp(self: interval, x: f64) f64 {
        if (x < self.min) {
            return self.min;
        } else if (x > self.max) {
            return self.max;
        } else {
            return x;
        }
    }

    const empty: interval = interval{ .min = helper.infinity, .max = -helper.infinity };
    const universe: interval = interval{ .min = -helper.infinity, .max = helper.infinity };
};
