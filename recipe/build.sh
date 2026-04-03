#!/bin/bash

set -xe

# Just to align with the Verilator installing docs
unset VERILATOR_ROOT

if [[ "$OS" == "Windows_NT" || "$(uname -s)" =~ MINGW|MSYS|CYGWIN ]]; then
    # Autoconf under MSYS should use a GNU-like toolchain, not cl.exe.
    cc_candidates=(
        "$BUILD_PREFIX/Library/mingw-w64/bin/x86_64-w64-mingw32-gcc.exe"
        "$BUILD_PREFIX/Library/mingw64/bin/x86_64-w64-mingw32-gcc.exe"
        "$BUILD_PREFIX/Library/mingw-w64/bin/gcc.exe"
        "$BUILD_PREFIX/Library/mingw64/bin/gcc.exe"
    )
    cxx_candidates=(
        "$BUILD_PREFIX/Library/mingw-w64/bin/x86_64-w64-mingw32-g++.exe"
        "$BUILD_PREFIX/Library/mingw64/bin/x86_64-w64-mingw32-g++.exe"
        "$BUILD_PREFIX/Library/mingw-w64/bin/g++.exe"
        "$BUILD_PREFIX/Library/mingw64/bin/g++.exe"
    )

    for cc in "${cc_candidates[@]}"; do
        [[ -x "$cc" ]] && export CC="$cc" && break
    done
    for cxx in "${cxx_candidates[@]}"; do
        [[ -x "$cxx" ]] && export CXX="$cxx" && break
    done

    if [[ -n "${CC:-}" && -n "${CXX:-}" ]]; then
        :
    elif command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1; then
        export CC=x86_64-w64-mingw32-gcc
        export CXX=x86_64-w64-mingw32-g++
    elif command -v x86_64-w64-mingw32-gcc-posix >/dev/null 2>&1; then
        export CC=x86_64-w64-mingw32-gcc-posix
        export CXX=x86_64-w64-mingw32-g++-posix
    elif command -v x86_64-w64-mingw32-gcc-win32 >/dev/null 2>&1; then
        export CC=x86_64-w64-mingw32-gcc-win32
        export CXX=x86_64-w64-mingw32-g++-win32
    elif command -v gcc >/dev/null 2>&1; then
        export CC=gcc
        export CXX=g++
    else
        echo "No GNU C/C++ compiler found in PATH on Windows/MSYS"
        exit 1
    fi
fi

echo "Using CC=${CC:-unset} CXX=${CXX:-unset}"

if [[ "$OS" == "Windows_NT" || "$(uname -s)" =~ MINGW|MSYS|CYGWIN ]]; then
    echo "Skipping autoconf on Windows; using bundled configure script"
else
    autoconf
fi
# as policy, conda-forge doesn't statically link any deps so --disable-partial-static
# see commit message at https://github.com/verilator/verilator/commit/f00ff61559be0c6a5cbd07f25e264ce3e8652145
# for details on what was being statically linked
#
# TODO consider adding --disable-defenv to configure to avoid baking the prefix into binaries
#      removing the need for the C-string patch for relocatability.  Would need to set
#      VERILATOR_ROOT and other env vars instead
CC="${CC:-gcc}" CXX="${CXX:-g++}" ./configure --prefix="$PREFIX" \
            --mandir="$PREFIX/man" \
            --disable-partial-static

# Set DTVERSION_rev to something more interesting than
# "UNKNOWN_REV (mod)" since we're building from tar and it
# won't ever show the git version
echo "static const char* const DTVERSION_rev = \"conda-forge build ${PKG_BUILDNUM}\";" > src/config_rev.h

make -j$CPU_COUNT
$STRIP ./bin/verilator_bin


if [[ "$(uname)" == "Darwin" ]]; then
    # static linking strategy of make_protect_lib example
    # doesn't work with clang on osx-64. End up with 
    #   ld: library not found for -lcrt0.o
    rm -rf examples/make_protect_lib

    # work around https://github.com/verilator/verilator/issues/3283
    export LDFLAGS="$LDFLAGS -undefined dynamic_lookup"
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
    # don't make test when cross compiling. At least until we figure out how to run in an emulator. qemu-static?
    make -j$CPU_COUNT test
fi


