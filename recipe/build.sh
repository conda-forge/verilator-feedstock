#!/bin/bash

set -xe

# Just to align with the Verilator installing docs
unset VERILATOR_ROOT

autoconf
# as policy, conda-forge doesn't statically link any deps so --disable-partial-static
./configure --prefix="$PREFIX" \
            --mandir="$PREFIX/man" \
            --disable-partial-static

# Set DTVERSION_rev to something more interesting than
# "UNKNOWN_REV (mod)" since we're building from tar and it
# won't ever show the git version
echo "static const char* const DTVERSION_rev = \"conda-forge built ${PKG_BUILD_STRING}\";" > src/config_rev.h

make -j$CPU_COUNT
$STRIP ./bin/verilator_bin


if [[ "$(uname)" == "Darwin" ]]; then
    # static linking strategy of make_protect_lib example
    # doesn't work with clang on osx-64. End up with 
    #   ld: library not found for -lcrt0.o
    rm -rf examples/make_protect_lib
fi

make -j$CPU_COUNT test


