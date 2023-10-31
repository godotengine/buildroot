#!/bin/bash

set -e

if [ -z $1 ]; then
  echo "usage: $0 arch"
  exit 1
fi

arch=$1

bin_to_keep="aclocal autom4te autoconf autoheader automake autoreconf cmake gawk libtool m4 meson ninja pkgconf pkg-config python python3.14 scons tar toolchain-wrapper wayland-scanner"
lib_to_keep="cmake gcc libexpat libpkgconf libpython3.14 libz libisl libmpc libmpfr libgmp libffi python3.14 pkgconfig libm libmvec libwayland libxml2"
share_to_keep="aclocal autoconf automake-1.16 autoconf-archive buildroot cmake gcc gettext-tiny libtool pkgconfig wayland"
sysroot_share_to_keep="aclocal pkgconfig wayland"

function clean_directory() {
  pushd $1
  files_to_keep="${@:2}"

  for file in $(ls -1); do
    keep_file=0
  
    if echo ${file} | grep -qe "^${arch}"; then
      keep_file=1
    fi
  
    for keep in ${files_to_keep}; do
      if echo ${file} | grep -qe "^${keep}"; then
        keep_file=1
        break
      fi
    done
  
    if [ ${keep_file} -eq 0 ]; then
      rm -rf ${file}
    fi
  done

  popd
}

# We only need a small handful of static libs
rm -f $(find -name *.a | grep -vE '(nonshared|gcc|libstdc++|librt|libpthread|libdl)')

# We strip all binaries for distribution
find -regex '.*\.so\(\..*\)?' -exec bin/${arch}-strip {} \; 2> /dev/null
find bin -exec bin/${arch}-strip {} \; 2> /dev/null
find ${arch}/bin -exec bin/${arch}-strip {} \; 2> /dev/null
find libexec/gcc -type f -exec bin/${arch}-strip {} \; 2> /dev/null

# Delete some large and unnecessary files
rm -rf sbin share/cmake-*/Help lib/python3*/site-packages/SCons/Tool/docbook
clean_directory bin ${bin_to_keep}
clean_directory lib ${lib_to_keep}
clean_directory share ${share_to_keep}
clean_directory ${arch}/sysroot/usr/share ${sysroot_share_to_keep}
find -name *.pyc -delete

# Create "unqualified" symlinks to all toolchain files
pushd bin
for file in ${arch}-*; do
  ln -s $file $(echo $file | sed -e "s/${arch}-//")
done
popd

# Cosmetic cleanups
#
# Remove files we removed from the reloc script
for file in $(cat share/buildroot/sdk-relocs); do
  if [ -e $file ]; then
    echo $file >> share/buildroot/sdk-relocs.new
  fi
done

mv share/buildroot/sdk-relocs.new share/buildroot/sdk-relocs
