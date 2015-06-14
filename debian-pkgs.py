#!/usr/bin/env python
#
#  debian-pkgs.py
#
#  Obtains Debian packages from the QT5 built binaries
#
#  Usage: debian-pkgs <sysroot mount> <picute path>
#
#

import sys
import os
import shutil
import glob

# simple and easy for now
qt5_version = '1.0.3'

# This is Debian control file in a skeleton reusable block
control_skeleton='''
Maintainer: Albert Casals <skarbat@gmail.com>
Section: others
Package: {pkg_name}
Version: {pkg_version}
Architecture: armhf
Depends: debconf (>= 0.5.00), {pkg_depends}
Priority: optional
Description: {pkg_description}

'''

# These are the X11 libraries on which QT5 depends on
libs_x11 = 'libx11-xcb1, libxcb-icccm4, libxcb-xfixes0, libxcb-image0, libxcb-keysyms1, libxcomposite1, ' \
    'libxcb-sync0, libxcb-randr0, libxcb-render-util0, libxrender1, libxext6, libxcb-glx0'

# These are the packages to build
packages=[

    { 'fileset': [ 'bin/*',
                   'imports',
                   'lib/lib*',
                   'lib/fonts/*',
                   'plugins',
                   'qml'
                   ],

      'pkg_name': 'picute-qt5',
      'pkg_version': qt5_version,
      'pkg_depends': '{}, libraspberrypi0'.format(libs_x11),
      'pkg_description': 'picute QT5 v5.4.1 runtime libraries and plugins' },

    { 'fileset': [ 'include', 'lib/cmake', 'lib/pkgconfig', 'translations' ],
      'pkg_name': 'picute-qt5-dev',
      'pkg_version': qt5_version,
      'pkg_depends': 'picute-qt5, libraspberrypi-dev',
      'pkg_description': 'picute QT5 v5.4.1 development files' }

    # TODO: QT Creator
]


if __name__ == '__main__':

    if len(sys.argv) < 2:
        print 'Syntax: debian-pkgs.py <sysroot directory> <qt directory>'
        print '        sysroot : pathname of the image mount point'
        print '        qt directory : pathname inside the root (i.e. /usr/local/picute/v5.4.1)'
        sys.exit(1)
    else:
        root_directory=sys.argv[1]
        source_directory=sys.argv[2]
        complete_source='{}/{}'.format(root_directory, source_directory)

    # Sanity check
    if not os.path.exists(complete_source):
        print 'error: path not found', complete_source
        sys.exit(1)

    for pkg in packages:

        # allocate a versioned directory name for the package
        versioned_pkg_name = 'pkgs/{}_{}'.format(pkg['pkg_name'], qt5_version)
        print 'Processing package {}...'.format(versioned_pkg_name)

        # extract the files from the root file system preparing them for packaging
        target_directory = '{}/{}'.format (versioned_pkg_name, source_directory)

        for files in pkg['fileset']:

            # Complete the pathname to the target directory
            last_path = os.path.dirname(files)
            target_files_path='{}/{}'.format(target_directory, last_path)

            print 'Extracting {} into {}...'.format(os.path.join(complete_source, files), target_files_path)
            if not os.path.exists(target_files_path):
                os.makedirs(target_files_path)

            os.system('cp -rvP {} {}'.format(os.path.join(complete_source, files), target_files_path))

        # create the Debian control file for "dpkg-deb" tool to know what to pack
        debian_dir=os.path.join(versioned_pkg_name, 'DEBIAN')
        if not os.path.exists(debian_dir):
            os.makedirs(debian_dir)
        with open(os.path.join(debian_dir, 'control'), 'w') as control_file:
            control_file.writelines(control_skeleton.format(**pkg))

        # dpkg-deb to collect files and generate debian package
        rc=os.system('dpkg-deb --build {}'.format(versioned_pkg_name))
        if not rc:
            print 'Package {} created correctly'.format(versioned_pkg_name)
        else:
            print 'WARNING: Error creating package {}'.format(versioned_pkg_name)
