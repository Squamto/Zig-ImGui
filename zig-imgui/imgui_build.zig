const std = @import("std");


// @src() is only allowed inside of a function, so we need this wrapper
fn srcFile() []const u8 { return @src().file; }
const sep = std.fs.path.sep_str;

pub const zig_imgui_mod_name = "Zig-ImGui";
pub const zig_imgui_lib_name = "cimgui";
const zig_imgui_path = std.fs.path.dirname(srcFile()).?;
const zig_imgui_file = zig_imgui_path ++ sep ++ "imgui.zig";

pub fn get_module(b: *std.Build) *std.Build.Module
{
    return b.addModule(zig_imgui_mod_name,.{
        .source_file = .{ .path = zig_imgui_path ++ sep ++ "imgui.zig" },
    });
}

pub fn link_c_source_files(exe: *std.Build.Step.Compile) void {
    const imgui_cpp_file = zig_imgui_path ++ sep ++ "cimgui_unity.cpp";

    exe.linkLibCpp();
    exe.addCSourceFiles(
        &[_][]const u8{ imgui_cpp_file },
        &[_][]const u8 {
            "-std=c++17",
            "-fno-sanitize=undefined",
            "-ffunction-sections",
            "-fvisibility=hidden",
        }
    );
}

pub fn get_artifact(
    b: *std.Build,
    freetype_dep: ?*std.Build.Dependency,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode
) *std.Build.Step.Compile {
    var cimgui = b.addStaticLibrary
    (
        .{
            .name = zig_imgui_lib_name,
            .target = target,
            .optimize = optimize,
        }
    );

    cimgui.linkLibCpp();
    if (freetype_dep != null)
    {
        cimgui.linkLibrary(freetype_dep.?.artifact("freetype"));
    }

    link_c_source_files(cimgui);
    return cimgui;
}

pub fn add_test_step(
    b: *std.build.Builder,
    step_name: []const u8,
    module: *std.Build.Module,
    lib: *std.Build.Step.Compile,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    const test_exe = b.addTest(
        .{
            .root_source_file = .{ .path = zig_imgui_path ++ std.fs.path.sep_str ++ "tests.zig" },
            .target = target,
            .optimize = optimize,
        }
    );

    test_exe.linkLibrary(lib);
    test_exe.addModule(zig_imgui_mod_name, module);

    const test_step = b.step(step_name, "Run zig-imgui tests");
    test_step.dependOn(&test_exe.step);
}
