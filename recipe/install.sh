#!/usr/bin/env bash

set -xe

case "$PKG_NAME" in
    verilator )
	# note, he doesn't provide configure argument to set pkgconfigdir so we override it into make
	make install pkgconfigdir="$PREFIX/lib/pkgconfig"

	rm "${PREFIX}/bin/verilator_bin_dbg"

	# fixup install location of cmake files to match conda-forge layout
	# This breaks cmake-based verilator examples because the cmake modules assume
	# they are within the verilator datadir
	#mkdir -p "$PREFIX/lib/cmake/verilator"
	#mv "$PREFIX"/share/verilator/*.cmake "$PREFIX"/lib/cmake/verilator/

	# fixup the prefix in verilated.mk so that it will get munged when installing the package
	# avoid weird BSD sed behavior of thinking the command is the backup extension by using perl
	perl -i -pe "s|$BUILD_PREFIX|$PREFIX|g" "$PREFIX/share/verilator/include/verilated.mk"

	set +e
	rg -l "$BUILD_PREFIX" "$PREFIX/share/verilator"
	if [[ $? -eq 0 ]]; then
	    echo "Found more occurances of \$BUILD_PREFIX in the files above"
	    echo "that likely need to be changed to \$PREFIX so that they can"
	    echo "be patched at install time by conda"
	    exit 1
	fi
	;;
    verilator-debug )
	mkdir -p "${PREFIX}/bin"
	(cd bin && /usr/bin/install -c verilator_bin_dbg "${PREFIX}/bin/verilator_bin_dbg")
	;;
    * )
	echo "Error: unknown package '$PKG_NAME'"
	exit 1
	;;
esac
