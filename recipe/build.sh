#!/bin/bash

set -xe

# Just to align with the Verilator installing docs
unset VERILATOR_ROOT

autoconf
./configure --prefix="$PREFIX"
make -j$CPU_COUNT

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
make install

sed -i "s|$BUILD_PREFIX|$PREFIX|g" $PREFIX/share/verilator/include/verilated.mk
