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

const Line = struct {
    p0: Vec2,
    p1: Vec2,

    const Self = @This();

    pub fn fromVec2(origin: Vec2, vec: Vec2) Self {
        return .{
            .p0 = origin,
            .p1 = Vec2{
                .x = origin.x + vec.x,
                .y = origin.y + vec.y,
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

fn println(
    y: i32,
    comptime fmt: []const u8,
    args: anytype,
) void {
    var buf: [20]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buf);

    std.fmt.format(stream.writer(), fmt, args) catch unreachable;
    w4.text(stream.getWritten(), 3, y);
}

var vector = Vec2.create(50, 0);
var origin_pt = Vec2.create(50, 50);
var rotation_rad: f32 = 0;

var started: bool = false;

export fn update() void {
    if (!started) println(2, "Press z/x/arrows", .{});

    const gamepad = w4.GAMEPAD1.*;

    if (gamepad != 0) started = true;

    var movement_vec = Vec2{ .x = 0, .y = 0 };
    if (gamepad & w4.BUTTON_RIGHT != 0) {
        movement_vec.x += 1;
    }
    if (gamepad & w4.BUTTON_LEFT != 0) {
        movement_vec.x -= 1;
    }
    if (gamepad & w4.BUTTON_UP != 0) {
        movement_vec.y -= 1;
    }
    if (gamepad & w4.BUTTON_DOWN != 0) {
        movement_vec.y += 1;
    }
    if (gamepad & w4.BUTTON_1 != 0) {
        rotation_rad += 0.002;
    }
    if (gamepad & w4.BUTTON_2 != 0) {
        rotation_rad -= 0.002;
    }

    origin_pt = origin_pt.add(movement_vec.normal());

    vector = vector.transform(Mat2.rotate(rotation_rad));
    const line = Line.fromVec2(origin_pt, vector)
        .translate(Vec2.create(vector.x / -2, vector.y / -2));
    line.draw();

    if (started) {
        println(120, "rad/s:{d:.2}", .{rotation_rad * 60});
        println(130, "O({d},{d})", .{ line.center().x, line.center().y });
        println(140, "len:{d:.2}", .{vector.length()});
        println(150, "mvmt:{d:.2},{d:.2}", .{ movement_vec.normal().x, movement_vec.normal().y });
    }
}

export fn start() void {
    w4.DRAW_COLORS.* = 2;
}
