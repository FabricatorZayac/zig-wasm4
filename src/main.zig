const w4 = @import("wasm4.zig");
const std = @import("std");

fn pow(x: anytype, y: u32) @TypeOf(x) {
    if (x == 0) return 0;
    if (y == 0) return 1;
    var x1 = x;
    for (1..y) |_| {
        x1 = x1 * x;
    }
    return x1;
}

const Mat2 = struct {
    mt: [2][2]f32,

    const Self = @This();

    pub fn identity() Self {
        return .{ .mt = .{
            .{ 1, 0 },
            .{ 0, 1 },
        } };
    }

    pub fn scale(a: f32) Self {
        return .{ .mt = .{
            .{ a, 0 },
            .{ 0, a },
        } };
    }

    pub fn rotate(angle_rad: f32) Self {
        return .{ .mt = .{
            .{ @cos(angle_rad), -@sin(angle_rad) },
            .{ @sin(angle_rad), @cos(angle_rad) },
        } };
    }
};

const Vec2 = struct {
    x: f32,
    y: f32,

    const Self = @This();

    pub fn create(x: f32, y: f32) Self {
        return .{ .x = x, .y = y };
    }

    pub fn fromLine(line: Line) Self {
        return .{
            .x = @floatFromInt(line.p1.x - line.p0.x),
            .y = @floatFromInt(line.p1.y - line.p0.y),
        };
    }

    pub fn length(self: Self) f32 {
        return @sqrt(self.x * self.x + self.y * self.y);
    }

    pub fn normal(self: Self) Self {
        return .{
            .x = self.x / self.length(),
            .y = self.y / self.length(),
        };
    }

    pub fn transform(self: Self, matrix: Mat2) Self {
        return .{
            .x = self.x * matrix.mt[0][0] + self.y * matrix.mt[1][0],
            .y = self.x * matrix.mt[0][1] + self.y * matrix.mt[1][1],
        };
    }
};

const Point = struct {
    x: i32,
    y: i32,

    const Self = @This();

    pub fn create(x: i32, y: i32) Self {
        return .{ .x = x, .y = y };
    }
};

const Line = struct {
    p0: Point,
    p1: Point,

    const Self = @This();

    pub fn fromPoints(p0: Point, p1: Point) Self {
        return .{
            .p0 = p0,
            .p1 = p1,
        };
    }

    pub fn fromVec2(origin: Point, vec: Vec2) Self {
        return .{
            .p0 = origin,
            .p1 = Point.create(
                origin.x + @as(i32, @intFromFloat(vec.x)),
                origin.y + @as(i32, @intFromFloat(vec.y)),
            ),
        };
    }

    pub fn draw(self: Self) void {
        w4.line(self.p0.x, self.p0.y, self.p1.x, self.p1.y);
    }

    pub fn center(self: Self) Point {
        return .{
            .x = @divTrunc(self.p0.x + self.p1.x, 2),
            .y = @divTrunc(self.p0.y + self.p1.y, 2),
        };
    }

    pub fn translate(self: Self, vec: Vec2) Self {
        return .{
            .p0 = .{
                .x = self.p0.x + @as(i32, @intFromFloat(vec.x)),
                .y = self.p0.y + @as(i32, @intFromFloat(vec.y)),
            },
            .p1 = .{
                .x = self.p1.x + @as(i32, @intFromFloat(vec.x)),
                .y = self.p1.y + @as(i32, @intFromFloat(vec.y)),
            },
        };
    }
};

fn println(
    y: i32,
    comptime fmt: []const u8,
    args: anytype,
) void {
    var buf: [20]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buf);

    std.fmt.format(stream.writer(), fmt, args) catch unreachable;
    w4.text(stream.getWritten(), 10, y);
}

var vector = Vec2.create(50, 0);

export fn update() void {
    println(90, "len:{d:.2}", .{vector.length()});

    vector = vector.transform(Mat2.rotate(0.04));

    const line = Line.fromVec2(Point.create(50, 50), vector)
        .translate(Vec2.create(vector.x / -2, vector.y / -2));
    line.draw();

    println(100, "x:{d:.2},y:{d:.2}", .{ vector.x, vector.y });
    println(110, "O({},{})", .{ line.center().x, line.center().y });
}

export fn start() void {
    w4.DRAW_COLORS.* = 2;
}
