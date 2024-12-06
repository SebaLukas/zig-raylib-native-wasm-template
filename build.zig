const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "example",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const target_os = exe.rootModuleTarget().os.tag;

    if (target_os == .freestanding) {
        exe.entry = .disabled;
        exe.rdynamic = true;
        exe.export_table = true;
    } else {
        const raylib_optimize = b.option(
            std.builtin.OptimizeMode,
            "raylib-optimize",
            "Prioritize performance, safety, or binary size (-O flag), defaults to value of optimize option",
        ) orelse optimize;

        const strip = b.option(
            bool,
            "strip",
            "Strip debug info to reduce binary size, defaults to false",
        ) orelse false;
        exe.root_module.strip = strip;

        const raylib_dep = b.dependency("raylib", .{
            .target = target,
            .optimize = raylib_optimize,
            .linux_display_backend = .X11,
        });
        exe.linkLibrary(raylib_dep.artifact("raylib"));
    }

    b.installArtifact(exe);

    if (target_os != .freestanding) {
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }
}
