const builtin = @import("builtin");

const ray = if (builtin.target.os.tag == .freestanding) @import("raylib.zig") else @cImport({
    @cInclude("raylib.h");
});

extern fn raylib_js_set_entry(callback: ?*const fn () callconv(.C) void) void;

fn game_frame() callconv(.C) void {
    ray.BeginDrawing();
    defer ray.EndDrawing();

    ray.ClearBackground(ray.RAYWHITE);

    ray.DrawText("Congrats! You created your first window!", 190, 200, 20, ray.LIGHTGRAY);
}

pub export fn main() void {
    const screenWidth = 800;
    const screenHeight = 450;

    ray.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window");
    defer ray.CloseWindow();

    ray.SetTargetFPS(60);

    if (builtin.target.os.tag == .freestanding) {
        raylib_js_set_entry(game_frame);
        return;
    }

    while (!ray.WindowShouldClose()) {
        game_frame();
    }
}
