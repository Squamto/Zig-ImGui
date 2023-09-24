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

    imgui_build.add_test_step(b, "test", target, optimize);

    // {
    //     const exe = example_exe(b, "example_glfw_vulkan", target, optimize);
    //     link_glfw(exe, target);
    //     link_vulkan(exe, target);

    //     const run_cmd = b.addRunArtifact(exe);
    //     run_cmd.step.dependOn(b.getInstallStep());
    //     if (b.args) |args| {
    //         run_cmd.addArgs(args);
    //     }

    //     const run_step = b.step("runvk", "Run the app with Vulkan");
    //     run_step.dependOn(&run_cmd.step);
    // }
    // {
    //     const exe = example_exe(b, "example_glfw_opengl3", target, optimize);
    //     link_glfw(exe, target);
    //     link_glad(exe);

    //     const run_cmd = b.addRunArtifact(exe);
    //     run_cmd.step.dependOn(b.getInstallStep());
    //     if (b.args) |args| {
    //         run_cmd.addArgs(args);
    //     }

    //     const run_step = b.step("rungl", "Run the app with OpenGL");
    //     run_step.dependOn(&run_cmd.step);
    // }
}

fn example_exe(
    b: *std.Build,
    comptime name: []const u8,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Step.Compile {
    const exe = b.addExecutable
    (
        .{
            .name = name,
            .root_source_file = .{ .path = "examples/" ++ name ++ ".zig" },
            .target = target,
            .optimize = optimize,
        }
    );

    imgui_build.link_module_and_lib(b, exe);
    b.installArtifact(exe);
    return exe;
}

fn link_glad(exe: *std.Build.Step.Compile) void {
    exe.addIncludePath(.{ .path = "examples/include/c_include" });
    exe.addCSourceFile(.{
        .file = .{ .path = "examples/c_src/glad.c" },
        .flags = &[_][]const u8{ "-std=c99" }
    });
}

fn link_glfw(exe: *std.Build.Step.Compile, target: std.zig.CrossTarget) void {
    if (target.isWindows()) {
        exe.addObjectFile(.{
            .path =
                if (target.getAbi() == .msvc)
                    "examples/lib/win/glfw3.lib"
                else
                    "examples/lib/win/libglfw3.a"
        });
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
