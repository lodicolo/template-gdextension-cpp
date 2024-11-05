#include "register_types.h"

#include "sample_node_2d.h"

#include <gdextension_interface.h>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

namespace sample {
    void initialize_extension(ModuleInitializationLevel p_level) {
        if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
            return;
        }

        UtilityFunctions::print("Initializing libsample GDExtension...");

        GDREGISTER_CLASS(SampleNode2D);
    }

    void destroy_extension(ModuleInitializationLevel p_level) {
        if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
            return;
        }

        UtilityFunctions::print("Destroying libsample GDExtension...");
    }
}

using namespace sample;

extern "C" {
    // Initialization.
    GDExtensionBool GDE_EXPORT sample_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
        godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

        init_obj.register_initializer(initialize_extension);
        init_obj.register_terminator(destroy_extension);
        init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

        return init_obj.init();
    }
}