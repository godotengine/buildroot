#!/bin/bash
set -e
 
function usage() {
  echo "usage: $0 host target"
  echo "  where host is one of linux-x86_64"
  echo "  where target is one of i686, x86_64, armv7, aarch64"
  exit 1
}

if [ -z $1 ] || [ -z $1 ]; then
  usage
fi

case $1 in
  linux-x86_64)
    host=$1
  ;;
  *)
    echo "unknown SDK host \"$1\""
    usage
esac

case $2 in
  i686)
    cp config-godot-i686 .config
    toolchain_prefix=i686-godot-linux-gnu
    bits=32
  ;;
  x86_64)
    cp config-godot-x86_64 .config
    toolchain_prefix=x86_64-godot-linux-gnu
    bits=64
  ;;
  armv7)
    cp config-godot-armv7 .config
    toolchain_prefix=arm-godot-linux-gnueabihf
    bits=32
  ;;
  aarch64)
    cp config-godot-aarch64 .config
    toolchain_prefix=aarch64-godot-linux-gnu
    bits=64
  ;;
  *)
    echo "unknown SDK target \"$2\""
    usage
  ;;
esac

if which podman &> /dev/null; then
  container=podman
elif which docker &> /dev/null; then
  container=docker
else
  echo "Podman or docker have to be in \$PATH"
  exit 1
fi

function build_linux_sdk() {
  ${container} build -f Dockerfile.linux-builder -t godot-buildroot-builder-linux
  ${container} run -it --rm -v $(pwd):/tmp/buildroot:z -w /tmp/buildroot -e FORCE_UNSAFE_CONFIGURE=1 --userns=keep-id godot-buildroot-builder-linux bash -c "make clean; make syncconfig; make sdk"

  mkdir -p godot-toolchains

  rm -fr godot-toolchains/${toolchain_prefix}_sdk-buildroot
  tar xf output/images/${toolchain_prefix}_sdk-buildroot.tar.gz -C godot-toolchains

  pushd godot-toolchains/${toolchain_prefix}_sdk-buildroot
  ../../clean-linux-toolchain.sh ${toolchain_prefix} ${bits}
  popd

  pushd godot-toolchains
  tar -cjf ${toolchain_prefix}_sdk-buildroot.tar.bz2 ${toolchain_prefix}_sdk-buildroot
  rm -rf ${toolchain_prefix}_sdk-buildroot
  popd
}

build_linux_sdk

echo
echo "***************************************"
echo "Build succesful your toolchain is in the godot-toolchains directory"
