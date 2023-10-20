const std = @import("std");
const builtin = @import("builtin");

const imgui_build = @import("zig-imgui/imgui_build.zig");

const glslc_command = if (builtin.os.tag == .windows) "tools/win/glslc.exe" else "glslc";

pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const enable_freetype = b.option(bool, "enable_freetype", "Enable building freetype as ImGui's font renderer.") orelse false;

    const enable_lunasvg = b.option(bool, "enable_lunasvg", "Enable building lunasvg to provide better emoji support in freetype. Requires freetype to be enabled.") orelse false;

    const enable_vulkan_backend = b.option(bool, "backend_vulkan", "Include Vulkan Backend Implementation.") orelse false;

    const enable_glfw_backend = b.option(bool, "backend_glfw", "Include GLFW Backend Implementation.") orelse false;

    const freetype_dep =
        if (enable_freetype)
        b.dependency("freetype", .{ .target = target, .optimize = optimize })
    else
        null;

    const module = imgui_build.get_module(b);
    const lib = imgui_build.get_artifact(
        b,
        freetype_dep,
        enable_lunasvg,
        enable_vulkan_backend,
        enable_glfw_backend,
        target,
        optimize,
    );
    b.installArtifact(lib);

    imgui_build.add_test_step(b, "test_imgui", module, lib, target, optimize);
}

fn example_exe(
    b: *std.Build,
    comptime name: []const u8,
    module: *std.Build.Module,
    lib: *std.Build.Step.Compile,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = "examples/" ++ name ++ ".zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibrary(lib);
    exe.addModule(imgui_build.zig_imgui_mod_name, module);

    b.installArtifact(exe);
    return exe;
}

fn link_glad(exe: *std.Build.Step.Compile) void {
    exe.addIncludePath(.{ .path = "examples/include/c_include" });
    exe.addCSourceFile(.{ .file = .{ .path = "examples/c_src/glad.c" }, .flags = &[_][]const u8{"-std=c99"} });
}

fn link_glfw(exe: *std.Build.Step.Compile, target: std.zig.CrossTarget) void {
    if (target.isWindows()) {
        exe.addObjectFile(.{ .path = if (target.getAbi() == .msvc)
            "examples/lib/win/glfw3.lib"
        else
            "examples/lib/win/libglfw3.a" });
        exe.linkSystemLibrary("gdi32");
        exe.linkSystemLibrary("shell32");
    } else {
        exe.linkSystemLibrary("glfw");
    }
}

fn link_vulkan(exe: *std.Build.Step.Compile, target: std.zig.CrossTarget) void {
    if (target.isWindows()) {
        exe.addObjectFile(.{ .path = "examples/lib/win/vulkan-1.lib" });
    } else {
        exe.linkSystemLibrary("vulkan");
    }
}
