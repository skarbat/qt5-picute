## Welcome to PiCute - QT5 running on the RaspberryPI

### What is this?

This is an automation tool to build the latest QT5 version inside a bootable RaspberryPI image.

QT5 official page: https://wiki.qt.io/Qt_5
Official repos: https://wiki.qt.io/Qt_Add_ons_Modules

It creates two versions of the library. One for developers which includes build tools, and one for runtime
which packages only the run-time libraries.

It will use a cross compiler for the runtime version, and will emulate ARM inside the image to build the developer
version. You should succeed using this tool against different RaspberrryPI distribution images, but pipaOS
XGUI version 3.5 is tested to work well.

### What do i need?

This tool has to run on an Intel based Debian or cousin system. Additionally it needs to have:

 * NBD kernel support
 * access to a fast Internet connection
 * user account with password-less sudo permissions
 * A correctly Qemu static ARM emulator setup, and the following packages:
  * python 2.7, build-essential, qemu-utils, binfmt-support and libfreetype6
 * ARM Cross compiler (to built the runtime image)
  *  Clone this repo into `/opt/rpi-tools`: git@github.com:raspberrypi/tools.git

### what do I have to do?

A normal build using pipaOS can be built straight away like this:

```
$ ./build-picute configs/pibuild-pipaos-xcb developer
```

Change `developer` to `runtime` to build the QT5 libraries alone.

Recommend to run it inside a screen session as this will take quite a long time.

### what next?

Burn the image to an SD card and boot it on a RaspberryPI. QT5 will be available at `/usr/local/picute/v.5.4.1`
The developer build will also contain a bunch of demos on the `examples` subdirectory.

Enjoy!
