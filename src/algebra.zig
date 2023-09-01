const std = @import("std");

pub const Mat2 = struct {
    mt: [2][2]f32,

    const Self = @This();

    pub fn identity() Self {
        return Self{ .mt = .{
            .{ 1, 0 },
            .{ 0, 1 },
        } };
    }

    pub fn scale(a: f32) Self {
        return Self{ .mt = .{
            .{ a, 0 },
            .{ 0, a },
        } };
    }

    pub fn rotate(angle_rad: f32) Self {
        return Self{ .mt = .{
            .{ @cos(angle_rad), -@sin(angle_rad) },
            .{ @sin(angle_rad), @cos(angle_rad) },
        } };
    }
};

pub const Vec2 = struct {
    x: f32,
    y: f32,

    const Self = @This();

    pub fn create(x: f32, y: f32) Self {
        return Self{ .x = x, .y = y };
    }

    pub fn length(self: Self) f32 {
        return @sqrt(self.x * self.x + self.y * self.y);
    }

    pub fn normal(self: Self) Self {
        var x = self.x / self.length();
        var y = self.y / self.length();
        if (std.math.isNan(x)) x = 0;
        if (std.math.isNan(y)) y = 0;
        return .{
            .x = x,
            .y = y,
        };
    }

    pub fn transform(self: Self, matrix: Mat2) Self {
        return .{
            .x = self.x * matrix.mt[0][0] + self.y * matrix.mt[1][0],
            .y = self.x * matrix.mt[0][1] + self.y * matrix.mt[1][1],
        };
    }

    pub fn add(self: Self, other: Self) Self {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
        };
    }
};
