const w4 = @import("wasm4.zig");
const std = @import("std");

const algebra = @import("algebra.zig");
const Vec2 = algebra.Vec2;
const Mat2 = algebra.Mat2;

const gfx = @import("gfx.zig");
const Line = gfx.Line;

fn println(
    y: i32,
    shadow: enum { Top, Bottom },
    comptime fmt: []const u8,
    args: anytype,
) void {
    var buf: [20]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buf);

    std.fmt.format(stream.writer(), fmt, args) catch unreachable;

    w4.DRAW_COLORS.* = 3;
    w4.text(stream.getWritten(), 2, switch (shadow) {
        .Top => y - 1,
        .Bottom => y + 1,
    });

    w4.DRAW_COLORS.* = 2;
    w4.text(stream.getWritten(), 3, y);
}

var vector = Vec2.create(50, 0);
var origin = Vec2.create(w4.SCREEN_SIZE / 2, w4.SCREEN_SIZE / 2);
var rotation_rad: f32 = 0;

var started: bool = false;

fn getMovement() Vec2 {
    const gamepad = w4.GAMEPAD1.*;

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
    return movement_vec.normal();
}

export fn update() void {
    if (!started) println(2, .Top, "Press z/x/arrows", .{});

    const gamepad = w4.GAMEPAD1.*;
    if (gamepad != 0) started = true;

    if (gamepad & w4.BUTTON_1 != 0) {
        rotation_rad += 0.002;
    }
    if (gamepad & w4.BUTTON_2 != 0) {
        rotation_rad -= 0.002;
    }

    const mvmt = getMovement();
    origin = origin.add(mvmt);

    vector = vector.transform(Mat2.rotate(rotation_rad));
    const line = Line.fromVec2(origin, vector)
        .translate(Vec2.create(vector.x / -2, vector.y / -2));
    w4.DRAW_COLORS.* = 3;
    line.draw();

    w4.DRAW_COLORS.* = 2;
    if (started) {
        println(120, .Bottom, "rad/s:{d:.2}", .{rotation_rad * 60});
        println(130, .Bottom, "O({d:.0},{d:.0})", .{ origin.x, origin.y });
        println(140, .Bottom, "len:{d:.2}", .{vector.length()});
        println(150, .Bottom, "mvmt:{d:.2},{d:.2}", .{ mvmt.x, mvmt.y });
    }
}

export fn start() void {}
