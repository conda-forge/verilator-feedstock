#!/usr/bin/env bash

set -xe

# ensure the pkgconfig files are installed correctly
pkg-config --print-provides "$PKG_NAME"

# He puts the date of the release in the version string for some
# reason, so this test won't work
#pkg-config --exact-version="$PKG_VERSION" "$PKG_NAME"

verilator --version

# the examples are packaged with verilator
cp -r "$PREFIX"/share/verilator/examples . && cd examples

# if CC and CXX aren't set, we're on Linux, set them to gcc g++
if [[ "${CC:-zz}" == zz ]]; then
    export CC=gcc
fi
if [[ "${CXX:-zz}" == zz ]]; then
    export CXX=g++
fi

# cmake needs more of the environment variables

for d in *; do 
    make -C $d
done
