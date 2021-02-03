# Godot buildroot

This repository contains the Godot buildroot to generate toolchains for building the Godot engine in a portable way for Linux. Using these toolchains is the best way to distribute Linux builds of your custom-compiled Godot game.

*You will only need this if you built the engine manually. If you use official templates you will not need this*

The toolchain current contains the following:
 * gcc-15.2.0
 * glibc-2.34
 * pulseaudio
 * alsa
 * X client libraries
 * udev
 * libGL
 * fontconfig
 * speechd
 * wayland client libraries

# Using the SDKs

This section is first because there's a lot of stuff below and this is likely what you came here for. Don't forget to check out the `Obtaining an SDK` section below!

The first part of an SDK filename referes to the architecture that this SDK will generate binaries *for*. If you want to ship your game to both 32bit and 64bit Intel/AMD users you will need both `x86_64-godot-linux-gnu_sdk-buildroot.tar.gz` and `i686-godot-linux-gnu_sdk-buildroot.tar.gz`.

Unpack the toolchain anywhere you like and run the `relocate-sdk.sh` script within. This needs to happen every time you move the toolchain to a different directory, but only needs to happen once after installation.

After this you can build the engine more-or-less like normal. For instance:

```
tar xf x86_64-godot-linux-gnu_sdk-buildroot.tar.gz
cd x86_64-godot-linux-gnu_sdk-buildroot
./relocate-sdk.sh
export PATH=$(pwd)/bin:$PATH
cd /path/to/godot/sources
scons arch=x86_64 production=yes  # for 64bit Intel/AMD systems
```

or for other platforms
```
scons arch=x86_32 production=yes  # for 32bit Intel/AMD systems
scons arch=arm32  production=yes  # For 32bit ARM systems 
scons arch=arm64  production=yes  # For 64bit ARM systems 
```

For other build-time options please see [Compiling for Linux](https://docs.godotengine.org/en/stable/contributing/development/compiling/compiling_for_linuxbsd.html).

# Obtaining an SDK

## Downloading a pre-built SDK

Pre-built toolchains are available on [GitHub Releases](https://github.com/godotengine/buildroot/releases/).

## Using buildroot to generate SDKs

###  Building a toolchain for local use

*Using this method will create a toolchain you yourself can use to create Godot releases that will work on any Linux system currently in use. However the toolchain you generate will not be portable to older Linuxes. If you plan to distribute the toolchain itself use the podman method below*

The basic steps for building a toolchain are:

 * copy `config-godot-<arch>` to `.config`
 * run `make olddefconfig`
 * run `make clean sdk`

Afterwards the SDK will be in `output/images/<arch>-godot-linux-gnu_sdk-buildroot.tar.gz`.

**NOTE: that `make clean sdk` will delete old builds. Move them out of the way first!**

###  Building a toolchain for distribution

This method uses a Alma Linux 9 container to make the buildroot *itself* portable so it can be distributed to other users. This is also the way the downloads above are generated.

 * run `./build-sdk.sh <arch>` for instance `x86_64`

The toolchain will appear in the `godot-toolchains` directory

## Modifying the toolchain

For detailed information please see https://buildroot.org however a short version is here:

**NOTE: re-running the build-sdk.sh script will overwrite your changes by default. Take care**

 * Copy the architecture you would like to change to `.config` for instance `cp config-godot-x86_64 .config`
 * Run `make menuconfig`
 * Make your changes

At this point your changes exist in .config. **Make a backup**. If you're building for local use just run `make clean sdk`, if you're using the container approach copy your `.config` file to the arch config like `config-godot-x64_64`

## Making Pull Requests for this repository

First of all: Thanks for wanting to help! Second of all: Since we support multiple architectures make sure that you make *the same* changes to all architectures and PR them together. If you *specifically* want to make a change to one architecture please note that clearly in the PR message.

Thanks!
