#!/bin/bash
#
# piguest.sh
#
# script runs inside the guest image to prepare the QT5 build dependencies
#

build_mode=$1
prefix=$2
mark_file="/var/cache/picute-bootstrapped"

echo "picute guest script running..."

if [ `uname -m` != "armv7l" ]; then
    echo "Does not look like we are in a ARM jail - aborting"
    exit 1
fi

if [ -f "$mark_file" ]; then
    echo "PiGuest has already been run - returning now"
    exit 0
fi

echo "Setting hostname to picute-$build_mode"
echo "picute-$build_mode" > /etc/hostname
echo "127.0.0.1   localhost" > /etc/hosts
echo "127.0.0.1   picute-$build_mode" >> /etc/hosts

echo "Enabling startx for everyone to enjoy!"
xwrapper_file=/etc/X11/Xwrapper.config
sed -i "/allowed_users/callowed_users=anybody\n" $xwrapper_file

echo "Installing the Xserver development libraries"
export DEBIAN_FRONTEND=noninteractive

dev_packages=" libc6-dev libxcb1-dev libxcb-icccm4-dev libxcb-xfixes0-dev libxcb-image0-dev libxcb-keysyms1-dev libxcomposite-dev \
libxcb-sync0-dev libxcb-randr0-dev libx11-xcb-dev libxcb-render-util0-dev libxrender-dev libxext-dev libxcb-glx0-dev \
libssl-dev libraspberrypi-dev libfreetype6-dev libxi-dev libcap-dev"

apt-get update
apt-get install -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" xserver-xorg xserver-xorg-video-fbdev xvfb $dev_packages

if [ "$build_mode" == "developer" ]; then

    # install gcc and g++ because we need to build QT5 natively
    apt-get install make libc6-dev libc-dev gcc-4.7 g++-4.7 pkg-config libbotan1.10-dev -y

    # set the default compiler to be 4.7 version
    # default build-essential installs version 4.6 which does not build QT5 correctly
    update-alternatives --install /usr/bin/g++ g++-4.7 $(which g++-4.7) 1

    update-alternatives --install /usr/bin/gcc gcc-4.7 $(which gcc-4.7) 1
    update-alternatives --install /usr/bin/gcc-ar gcc-ar-4.7 $(which gcc-ar-4.7) 1
    update-alternatives --install /usr/bin/gcc-nm gcc-nm-4.7 $(which gcc-nm-4.7) 1
    update-alternatives --install /usr/bin/gcc-ranlib gcc-ranlib-4.7 $(which gcc-ranlib-4.7) 1
    update-alternatives --install /usr/bin/gcov gcov-4.7 $(which gcov-4.7) 1
fi

# Add library and binary paths, plus qt5 variables to play nice with touch devices
# Taken from recipe: https://wiki.qt.io/Native_Build_of_Qt_5.4.1_on_a_Raspberry_Pi
# FIXME: hardcoded paths!

cat >>/etc/bash.bashrc <<EOF

# QT5 tools and libraries
export LD_LIBRARY_PATH=$prefix/lib
export PATH=$prefix/bin:$PATH

# hides mouse cursor
export QT_QPA_EGLFS_HIDECURSOR=0

# enables tslib plugin for touch screen
#export QT_QPA_GENERIC_PLUGINS=Tslib

# disables evdev mouse input (to avoid getting duplicated input from tslib AND evdev)
export QT_QPA_EGLFS_DISABLE_INPUT=0

# set physical display dimensions for proper font sizes etc.
# Qt should print a warning if this is necessary
export QT_QPA_EGLFS_PHYSICAL_WIDTH=154
export QT_QPA_EGLFS_PHYSICAL_HEIGHT=86

alias qtcreator-xcb="qtcreator -platform xcb -noload Welcome"

EOF

# We are running short of disk space
apt-get clean -y
apt-get autoclean -y

# put a mark file so we don't run endlessly
touch "$mark_file"
exit 0
