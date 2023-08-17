// Graphics primitives
const Vec2 = @import("algebra.zig").Vec2;
const w4 = @import("wasm4.zig");

pub const Line = struct {
    p0: Vec2,
    p1: Vec2,

    const Self = @This();

    pub fn fromVec2(orig: Vec2, vec: Vec2) Self {
        return .{
            .p0 = orig,
            .p1 = Vec2{
                .x = orig.x + vec.x,
                .y = orig.y + vec.y,
            },
        };
    }

    pub fn draw(self: Self) void {
        w4.line(
            @intFromFloat(self.p0.x),
            @intFromFloat(self.p0.y),
            @intFromFloat(self.p1.x),
            @intFromFloat(self.p1.y),
        );
    }

    pub fn center(self: Self) Vec2 {
        return .{
            .x = @divTrunc(self.p0.x + self.p1.x, 2),
            .y = @divTrunc(self.p0.y + self.p1.y, 2),
        };
    }

    pub fn translate(self: Self, vec: Vec2) Self {
        return .{
            .p0 = .{
                .x = self.p0.x + vec.x,
                .y = self.p0.y + vec.y,
            },
            .p1 = .{
                .x = self.p1.x + vec.x,
                .y = self.p1.y + vec.y,
            },
        };
    }
};
