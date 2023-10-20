const std = @import("std");

// @src() is only allowed inside of a function, so we need this wrapper
fn srcFile() []const u8 {
    return @src().file;
}

pub const zig_imgui_lib_name = "cimgui";
pub const zig_imgui_mod_name = "Zig-ImGui";
const zig_imgui_path = std.fs.path.dirname(srcFile()).?;

pub fn get_module(b: *std.Build) *std.Build.Module {
    return b.addModule(zig_imgui_mod_name, .{
        .source_file = .{ .path = b.pathJoin(&[_][]const u8{
            zig_imgui_path,
            "imgui.zig",
        }) },
    });
}

pub fn link_cimgui_source_files(b: *std.Build, exe: *std.Build.Step.Compile) void {
    exe.addCSourceFile(.{
        .file = .{ .path = b.pathJoin(&[_][]const u8{
            zig_imgui_path,
            "vendor",
            "cimgui",
            "cimgui_unity.cpp",
        }) },
        .flags = &[_][]const u8{
            "-std=c++11",
            "-fno-sanitize=undefined",
            "-ffunction-sections",
            "-fvisibility=hidden",
        },
    });
}

pub fn addVulkanBackendImplementation(b: *std.Build, exe: *std.Build.Step.Compile, vulkan_include_path: []const u8) void {
    _ = vulkan_include_path;
    // exe.addIncludePath(.{
    //     .cwd_relative = b.pathJoin(&[_][]const u8{
    //         vulkan_include_path,
    //         "Include",
    //     }),
    // });

    exe.addCSourceFile(.{
        .file = .{ .path = b.pathJoin(&[_][]const u8{
            zig_imgui_path,
            "vendor",
            "cimgui",
            "imgui",
            "imgui_impl_vulkan.cpp",
        }) },
        .flags = &[_][]const u8{
            "-std=c++11",
            "-fno-sanitize=undefined",
            "-ffunction-sections",
            "-fvisibility=hidden",
        },
    });
}

pub fn addGlfwBackendImplementation(b: *std.Build, exe: *std.Build.Step.Compile) void {
    exe.addCSourceFile(.{
        .file = .{ .path = b.pathJoin(&[_][]const u8{
            zig_imgui_path,
            "vendor",
            "cimgui",
            "imgui",
            "imgui_impl_glfw.cpp",
        }) },
        .flags = &[_][]const u8{
            "-std=c++11",
            "-fno-sanitize=undefined",
            "-ffunction-sections",
            "-fvisibility=hidden",
        },
    });
}

pub fn link_lunasvg_source_files(b: *std.Build, exe: *std.Build.Step.Compile) void {
    const lunasvg_path = b.pathJoin(&[_][]const u8{
        zig_imgui_path,
        "vendor",
        "lunasvg",
    });

    exe.addIncludePath(.{ .path = b.pathJoin(&[_][]const u8{ lunasvg_path, "3rdparty", "plutovg" }) });
    exe.addCSourceFiles(&[_][]const u8{
        b.pathJoin(&[_][]const u8{ lunasvg_path, "3rdparty", "plutovg", "plutovg.c" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "3rdparty", "plutovg", "plutovg-paint.c" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "3rdparty", "plutovg", "plutovg-geometry.c" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "3rdparty", "plutovg", "plutovg-blend.c" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "3rdparty", "plutovg", "plutovg-rle.c" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "3rdparty", "plutovg", "plutovg-dash.c" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "3rdparty", "plutovg", "plutovg-ft-raster.c" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "3rdparty", "plutovg", "plutovg-ft-stroker.c" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "3rdparty", "plutovg", "plutovg-ft-math.c" }),
    }, &[_][]const u8{
        "-std=c11",
        "-fno-sanitize=undefined",
        "-ffunction-sections",
        "-fvisibility=hidden",
    });

    exe.addIncludePath(.{ .path = b.pathJoin(&[_][]const u8{ lunasvg_path, "include" }) });
    exe.addCSourceFiles(&[_][]const u8{
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "lunasvg.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "element.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "property.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "parser.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "layoutcontext.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "canvas.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "clippathelement.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "defselement.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "gelement.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "geometryelement.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "graphicselement.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "maskelement.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "markerelement.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "paintelement.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "stopelement.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "styledelement.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "styleelement.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "svgelement.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "symbolelement.cpp" }),
        b.pathJoin(&[_][]const u8{ lunasvg_path, "source", "useelement.cpp" }),
    }, &[_][]const u8{
        "-std=c++11",
        "-fno-sanitize=undefined",
        "-ffunction-sections",
        "-fvisibility=hidden",
    });
}

pub fn get_artifact(
    b: *std.Build,
    freetype_dep: ?*std.Build.Dependency,
    enable_lunasvg: bool,
    vulkan_include_path: ?[]const u8,
    include_glfw_backend: bool,
    glfw_dependency: *std.Build.Dependency,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
) !*std.Build.Step.Compile {
    var cimgui = b.addStaticLibrary(.{
        .name = zig_imgui_lib_name,
        .target = target,
        .optimize = optimize,
    });

    cimgui.linkLibCpp();
    if (freetype_dep != null) {
        cimgui.defineCMacro("IMGUI_ENABLE_FREETYPE", "1");
        cimgui.defineCMacro("CIMGUI_FREETYPE", "1");
        cimgui.linkLibrary(freetype_dep.?.artifact("freetype"));
    }

    if (enable_lunasvg) {
        cimgui.defineCMacro("IMGUI_ENABLE_FREETYPE_LUNASVG", "1");
        link_lunasvg_source_files(b, cimgui);
    }

    try @import("mach_glfw").link(glfw_dependency.builder, cimgui);

    if (vulkan_include_path) |vk_path| {
        addVulkanBackendImplementation(b, cimgui, vk_path);
    }

    if (include_glfw_backend) {
        addGlfwBackendImplementation(b, cimgui);
    }

    link_cimgui_source_files(b, cimgui);
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
    const test_exe = b.addTest(.{
        .root_source_file = .{ .path = b.pathJoin(&[_][]const u8{
            zig_imgui_path,
            "tests.zig",
        }) },
        .target = target,
        .optimize = optimize,
    });

    test_exe.linkLibrary(lib);
    test_exe.addModule(zig_imgui_mod_name, module);

    const test_step = b.step(step_name, "Run zig-imgui tests");
    test_step.dependOn(&test_exe.step);
}
