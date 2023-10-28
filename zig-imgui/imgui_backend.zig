const std = @import("std");

fn joinWithLocation(path: []const u8) []const u8 {
    const allocator = std.heap.page_allocator;

    const src: std.builtin.SourceLocation = @src();

    const base = src.file;

    const joined = std.fs.path.join(allocator, .{
        base, path,
    });
    defer allocator.free(joined);
    return joined;
}

pub const c = @cImport({
    @cInclude(joinWithLocation("vendor/cimgui/imgui/imgui.h"));
    @cInclude(joinWithLocation("vendor/cimgui/imgui/imgui_impl_vulkan.h"));
});
