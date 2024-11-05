#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

_script_name="$(basename -- "${BASH_SOURCE[0]}")"

_platform=$1
if [ "$_platform" = "" ]; then
    echo -e "${RED}[FATAL] Platform not specified as first argument${NOCOLOR}"
    echo -e "Usage: $_script_name <platform>"
    exit 1
fi

_build_mode=$(echo "$2" | tr '[:upper:]' '[:lower:]')
case "$_build_mode" in
    "")
        _build_mode=debug
        ;;
    
    "debug")
        ;;
    
    "release")
        ;;
    
    *)
        echo -e "${RED}[FATAL] Invalid build mode: '$_build_mode' must be one of 'debug' or 'release' (case insensitive) ${NOCOLOR}"
        exit 2
esac

PATH_REPO_ROOT="$(realpath "$(dirname -- "${BASH_SOURCE[0]}")")"

#region Build extensions (scons)

echo "Building repo located at $PATH_REPO_ROOT"

if [ "$_platform" != web ]; then
    _scons_params="$_scons_params bits=64"
fi

if ! scons --no-cache -j12 use_llvm=yes target=template_$_build_mode debug_symbols=yes platform=$_platform $_scons_params ; then
    echo -e "${RED}[FATAL] Error compiling extensions"
    exit 1
fi

#endregion Build extensions (scons)

#region Check for linker errors

echo "Checking for linker errors..."

_LINKER_ISSUES=0

for filename in ./extensions/*/bin/* ; do
    echo -e "Checking ${filename}"
    case "$filename" in
        "*.wasm")
            ;;
        "*.so*")
            _LDD_OUTPUT=$(ldd -d -r $filename)

            if [ $? -ne 0 ] ; then
                echo -e "${RED}[FATAL] Failed to run ldd against ${filename} ${NOCOLOR}"
                _LINKER_ISSUES=1
            else
                _UNDEFINED_SYMBOLS=$(_tab=$'\t' ; grep 'undefined symbol:' <<< $_LDD_OUTPUT | sed "s/^/$_tab/" | sed "s/^$_tab$//")
                if [ -n "$_UNDEFINED_SYMBOLS" ] ; then
                    echo -e "${RED}[FATAL] Found undefined symbols in ${filename}: ${NOCOLOR}\n${_UNDEFINED_SYMBOLS}"
                    _LINKER_ISSUES=1
                fi
            fi
    esac
done

if [ $_LINKER_ISSUES -ne 0 ] ; then
    echo -e "${RED}[FATAL] Linker issues found, please look above this line for which binaries failed ${NOCOLOR}"
    exit 2
else
    echo "No linker errors found"
fi

#endregion Check for linker errors

echo -e "${GREEN}Build succeeded"
