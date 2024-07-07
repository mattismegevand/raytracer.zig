const std = @import("std");
const helper = @import("helper.zig");

pub const Interval = struct {
    min: f64,
    max: f64,

    pub fn default() Interval {
        return .{ .min = helper.infinity, .max = -helper.infinity };
    }

    pub fn init(min: f64, max: f64) Interval {
        return .{ .min = min, .max = max };
    }

    pub fn size(self: Interval) f64 {
        return self.max - self.min;
    }

    pub fn contains(self: Interval, x: f64) bool {
        return self.min <= x and x <= self.max;
    }

    pub fn surrounds(self: Interval, x: f64) bool {
        return self.min < x and x < self.max;
    }

    pub fn clamp(self: Interval, x: f64) f64 {
        if (x < self.min) {
            return self.min;
        } else if (x > self.max) {
            return self.max;
        } else {
            return x;
        }
    }

    const empty = init(helper.infinity, -helper.infinity);
    const universe = init(-helper.infinity, helper.infinity);
};
