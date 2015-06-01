#!/bin/bash

MOUNTP=$1

if [ "$MOUNTP" == "" ]; then
    echo "Ups... Need the path to the root filesystem"
    exit 1
fi

# Fixing paths to libdl.so (dlopen) and libm.so (libc6) shared objects inside the image
# This is because the relative paths are not coherent from the host view of the root file system
# FIXME: This patch is very sensitive to system upgrades, revise if you get build errors
echo "Fixing relative paths to LIBDL and LIBM shared objects"

# lidbl for dlopen familiy of functions
libdl="/usr/lib/arm-linux-gnueabihf/libdl.so"
target_libdl=`readlink $MOUNTP/$libdl`
if [ "$?" == "0" ]; then
    echo "fixing absolute path to: $target_libdl"
    sudo rm -fv $MOUNTP/$libdl
    sudo cp -fv $MOUNTP/$target_libdl $MOUNTP/$libdl
else
    echo "LIBDL looks good"
    ls -l $MOUNTP/$libdl
fi

# libm for dlopen familiy of functions
# FIXME: This only works for Raspbian Wheezy, it will eventually fail!
libm="/usr/lib/arm-linux-gnueabihf/libm.so"
target_libm=`readlink $MOUNTP/$libm`
if [ "$?" == "0" ]; then
    echo "fixing absolute path to: $target_libm"
    sudo rm -fv $MOUNTP/$libm
    sudo cp -fv $MOUNTP/$target_libm $MOUNTP/$libm
else
    echo "LIBM looks good"
    ls -l $MOUNTP/$libm
fi

exit 0
