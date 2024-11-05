#!/usr/bin/env bash

RED='\033[0;31m'
NOCOLOR='\033[0m'

_script_name="$(basename -- "${BASH_SOURCE[0]}")"

_platform=$1
if [ "$_platform" = "" ]; then
    echo -e "${RED}[FATAL] Platform not specified as first argument${NOCOLOR}"
    echo -e "Usage: $_script_name <platform>"
    exit 1
fi

PATH_REPO_ROOT="$(realpath "$(dirname -- "${BASH_SOURCE[0]}")")"
echo "Preparing repo located at $PATH_REPO_ROOT"

PATH_VENDORS="$PATH_REPO_ROOT/vendor"

PATH_GODOT="$(realpath "$(which $(cat .godot-path))")"
echo "godot executable located at $PATH_GODOT"

if [[ -f "$PATH_REPO_ROOT"/godot ]]; then
    rm "$PATH_REPO_ROOT"/godot
fi
ln -s $PATH_GODOT godot

# Update submodules

# Update godot-cpp
PATH_GODOT_CPP="$PATH_VENDORS"/godot-cpp
echo "godot-cpp located at $PATH_GODOT_CPP"
cd "$PATH_VENDORS"/godot-cpp
git submodule update --init --recursive

echo "Dumping extension_api.json into repository root..."
cd $PATH_REPO_ROOT
$PATH_GODOT --headless --dump-extension-api

echo "Dumping extension_api.json and gdextension_interface.h into godot-cpp..."
cd $PATH_GODOT_CPP/gdextension
$PATH_GODOT --headless --dump-extension-api --dump-gdextension-interface

echo "Building godot-cpp for $_platform"
cd $PATH_GODOT_CPP
scons -j12 platform=$_platform use_llvm=yes custom_api_file=../../extension_api.json $_scons_params