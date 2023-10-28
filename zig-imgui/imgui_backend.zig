// pub const c = @cImport({
//     @cInclude("vendor/cimgui/imgui/imgui_impl_vulkan.h");
//     @cInclude("vendor/cimgui/imgui/imgui_impl_glfw.h");
// });

const std = @import("std");

const glfw = @import("mach_glfw");

pub extern fn ImGui_ImplGlfw_InitForVulkan(window: glfw.Window, install_callbacks: bool) bool;

test "123" {
    std.testing.refAllDecls(@This());
}
