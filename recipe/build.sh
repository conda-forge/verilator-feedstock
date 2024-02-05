#!/bin/bash

set -xe

# Just to align with the Verilator installing docs
unset VERILATOR_ROOT

autoconf
# as policy, conda-forge doesn't statically link any deps so --disable-partial-static
# see commit message at https://github.com/verilator/verilator/commit/f00ff61559be0c6a5cbd07f25e264ce3e8652145
# for details on what was being statically linked
#
# TODO consider adding --disable-defenv to configure to avoid baking the prefix into binaries
#      removing the need for the C-string patch for relocatability.  Would need to set
#      VERILATOR_ROOT and other env vars instead
./configure --prefix="$PREFIX" \
            --mandir="$PREFIX/man" \
            --disable-partial-static

# Set DTVERSION_rev to something more interesting than
# "UNKNOWN_REV (mod)" since we're building from tar and it
# won't ever show the git version
echo "static const char* const DTVERSION_rev = \"conda-forge build ${PKG_BUILDNUM}\";" > src/config_rev.h

make -j$CPU_COUNT
ls -lh ./bin/
$STRIP ./bin/verilator_bin
ls -lh ./bin/


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


