#define IMGUI_DISABLE_OBSOLETE_FUNCTIONS 1
#define IMGUI_DISABLE_OBSOLETE_KEYIO 1
#define IMGUI_USE_WCHAR32 1
#define IMGUI_IMPL_API extern "C"

#include "imgui/imgui.cpp"
#include "imgui/imgui_draw.cpp"
#include "imgui/imgui_demo.cpp"
#include "imgui/imgui_tables.cpp"
#include "imgui/imgui_widgets.cpp"
#ifdef IMGUI_ENABLE_FREETYPE
#include "imgui/imgui_freetype.cpp"
#endif

#define GLFW_INCLUDE_NONE
#define GLFW_INCLUDE_VULKAN
#include "imgui/imgui_impl_glfw.cpp"
#include "imgui/imgui_impl_vulkan.cpp"

#include "cimgui.cpp"

