#pragma once

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

namespace sample {
    void initialize_extension(ModuleInitializationLevel p_level);
    void destroy_extension(ModuleInitializationLevel p_level);
}