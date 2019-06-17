#!/bin/sh

#
# Copyright (C) Vamsi.  2017-18 All rights reserved.
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions
# of the GNU General Public License version 2.
#

current_location=$PWD
cd "$current_location/ns-allinone-3.29/ns-3.29/"
chmod +x waf

# For new GCC version, disable a compiler flag
curVersion="$(gcc -dumpversion)"
newVersion="7.0.0"
if [ "$(printf '%s\n' "$newVersion" "$curVersion" | sort -V | head -n1)" = "$newVersion" ]; then 
	./waf configure CXXFLAGS="-Wno-error=int-in-bool-context"
else
	./waf configure 
fi

./waf clean
./waf build
cd "$current_location/native/mlPhy"
sh compile.sh
cd "$current_location/native/mexBindings"
make
cd "$current_location"
