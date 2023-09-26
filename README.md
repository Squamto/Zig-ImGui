# Zig-ImGui

Zig-ImGui uses [cimgui](https://github.com/cimgui/cimgui) to generate [Zig](https://github.com/ziglang/zig) bindings for [Dear ImGui](https://github.com/ocornut/imgui).

It is currently up to date with [Dear ImGui v1.89.9](https://github.com/ocornut/imgui/releases/tag/v1.89.9).

At the time of writing, Zig-ImGui supports zig `0.11.0` and `0.12.0-dev.589+731fd217d`

## Using the pre-generated bindings

Zig-ImGui strives to be easy to use.  To use the pre-generated bindings, do the following:

- Copy from the following dependency section into your project's `build.zig.zon` file:
    ```zig
    .{
        .name = "myproject",
        .version = "1.0.0", // whatever your version is
        .dependencies =
        .{
            .ZigImGui =
            .{
                // https://multiformats.io/multihash/#sha2-256-256-bits-aka-sha256
                // "1220" + sha256sum of folder contents
                // run zig build with a url and fake hash to cause zig to generate
                // an error message with the expected hash, ex:
                // .url = "https://whatever.com/file.tar.gz"
                // .hash = "12200000000000000000000000000000000000000000000000000000000000000000"
                .hash = "1220ccb76517a0feca6ab27f9100a0d9afe5d974309ee2c7e4dc3fc754a0b71695b1",
                // Make sure to grab the latest commit version and not whatever is in this sample here
                .url = "https://github.com/joshua-software-dev/Zig-ImGui/archive/6fcbd57e5b1b1ac3b21f0eba4cdf27bacc198116.tar.gz",
            },
        },
    }
    ```
- In your build.zig, add the following:
    ```zig
    const ZigImGui_dep = b.dependency("ZigImGui", .{
        .target = target,
        .optimize = optimize,
        // Include support for using freetype font rendering in addition to
        // ImGui's default truetype, necessary for emoji support
        //
        // Note: ImGui will prefer using freetype by default when this option
        // is enabled, but the option to use typetype manually at runtime is
        // still available
        .enable_freetype = true, // if unspecified, the default is false
        // Enable ImGui's extention to freetype which uses lunasvg:
        // https://github.com/sammycage/lunasvg
        // to support SVGinOT (SVG in Open Type) color emojis
        //
        // Notes from ImGui's documentation:
        // * Not all types of color fonts are supported by FreeType at the
        //   moment.
        // * Stateful Unicode features such as skin tone modifiers are not
        //   supported by the text renderer.
        .enable_lunasvg = false // if unspecified, the default is false
    });
    ```
- In your project, use `@import("Zig-ImGui")` to obtain the bindings.
- For more detailed documentation, see the [official ImGui documentation](https://github.com/ocornut/imgui/tree/v1.88/docs).
- For an example of a real project using these bindings, see [joshua-software-dev/Lurk](https://github.com/joshua-software-dev/Lurk).

## Binding style

These bindings generally prefer the original ImGui naming styles over Zig style.  Functions, types, and fields match the casing of the original.  Prefixes like ImGui* or Im* have been stripped.  Enum names as prefixes to enum values have also been stripped.

"Flags" enums have been translated to packed structs of bools, with helper functions for performing bit operations.  ImGuiCond specifically has been translated to CondFlags to match the naming style of other flag enums.

Const reference parameters have been translated to by-value parameters, which the Zig compiler will implement as by-const-reference with extra restrictions.  Mutable reference parameters have been converted to pointers.

Functions with default values have two generated variants.  The original name maps to the "simple" version with all defaults set.  Adding "Ext" to the end of the function will produce the more complex version with all available parameters.

Functions with multiple overloads have a postfix appended based on the first difference in parameter types.

For example, these two C++ functions generate four Zig functions:
```c++
void ImGui::SetWindowCollapsed(char const *name, bool collapsed, ImGuiCond cond = 0);
void ImGui::SetWindowCollapsed(bool collapsed, ImGuiCond cond = 0);
```
```zig
fn SetWindowCollapsed_Str(name: ?[*:0]const u8, collapsed: bool) void;
fn SetWindowCollapsed_StrExt(name: ?[*:0]const u8, collapsed: bool, cond: CondFlags) void;
fn SetWindowCollapsed_Bool(collapsed: bool) void;
fn SetWindowCollapsed_BoolExt(collapsed: bool, cond: CondFlags) void;
```

Nullability and array-ness of pointer parameters is hand-tuned by the logic in pointer_rules.py.  If you find any incorrect translations, please open an issue.

## Generating new bindings

To use a different version of Dear ImGui, new bindings need to be generated.
You will need to do some setup for this:

- Download and install luajit, and add it to your path
- Download and install gcc, through mingw or other means, and add it to your path
- Download and install Python 3, and add it to your path

Once you are set up, run `generate.bat` to attempt to generate the bindings.

NOTE: `generate.bat` will revert any local changes in the cimgui submodule, so don't run it if you have any.

Some changes to Dear ImGui may require more in-depth changes to generate correct bindings.
You may need to check for updates to upstream cimgui, or add rules to pointer_rules.py.

You can do a quick check of the integrity of the bindings with `zig build test`.  This will verify that the version of Dear ImGui matches the bindings, and compile all wrapper functions in the bindings.
