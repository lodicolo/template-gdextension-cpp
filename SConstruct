#!/usr/bin/env python
import os
import sys

from glob import glob
from pathlib import Path

env = SConscript("vendor/godot-cpp/SConstruct")

# For reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# Add targets for all detected extensions
for extension_path in glob("extensions/*/*.gdextension"):
    extension_dir_path = Path(extension_path).parent
    extension_name = extension_dir_path.stem

    extension_src_path = extension_dir_path.joinpath('src')
    extension_bin_path = extension_dir_path.joinpath('bin')
    extension_src_glob_string = extension_src_path.joinpath('*.cpp')

    # Find all .cpp source files
    env.Append(CPPPATH=[str(extension_src_path)])
    extension_sources = Glob(extension_src_glob_string)
    for root, dirs, files in os.walk(str(extension_src_path), topdown=False):
        for dir in dirs:
            subdir_glob_string = os.path.join(root, dir, "*.cpp")
            extension_sources = extension_sources + Glob(subdir_glob_string)

    # Add documentation
    extension_doc_path = extension_dir_path.joinpath('doc_classes')
    extension_doc_glob_string = extension_doc_path.joinpath('*.xml')
    if env["target"] in ["editor", "template_debug"]:
        try:
            doc_data_path = extension_src_path.joinpath("gen", "doc_data.gen.cpp")
            doc_data = env.GodotCPPDocData(doc_data_path, source=Glob(extension_doc_glob_string))
            for doc_data_entry in doc_data:
                if doc_data_entry not in extension_sources:
                    extension_sources.append(doc_data_entry)
        except AttributeError:
            print("Not including class reference as we're targeting a pre-4.3 baseline.")

    print("sources for %s:" % extension_name)
    for source in extension_sources:
        print("\t%s" % source)

    # Create the library target (e.g. libexample.linux.debug.x86_64.so).
    debug_or_release = "release" if env["target"] == "template_release" else "template_debug"

    extension_library_name = "{}/bin/lib{}.{}.{}.{}{}".format(
        extension_dir_path,
        extension_name,
        env["platform"],
        debug_or_release,
        env["arch"],
        env["SHLIBSUFFIX"],
    )

    if env["platform"] == "macos":
        extension_library_name = "{0}/bin/lib{1}.{2}.{3}.framework/{1}.{2}.{3}".format(
            extension_dir_path,
            extension_name,
            env["platform"],
            debug_or_release,
        )

    extension_library = env.SharedLibrary(
        extension_library_name,
        source=extension_sources,
    )

    Default(extension_library)

from SCons import __version__ as scons_raw_version
scons_ver = env._get_major_minor_revision(scons_raw_version)
if scons_ver >= (4, 0, 0):
  env.Tool("compilation_db")
  cdb = env.CompilationDatabase()
  env.Alias("compiledb", cdb)
  Default(cdb)