#!/bin/bash
VERSION=1.0
HEX2BIN_DIR=c

# PREFIX must be an absolute path
# PREFIX must be exported for "make" subshell
export PREFIX=${PREFIX:-/opt/mtwilson/share/hex2bin}
export LINUX_TARGET=${LINUX_TARGET:-generic}
export CFLAGS="-fstack-protector-strong -fPIE -fPIC -O2 -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security"
export LDFLAGS="-z noexecstack -z relro -z now -pie"


install_hex2bin() {
  echo "PREFIX=$PREFIX"
  mkdir -p $PREFIX
  if [ -d "$HEX2BIN_DIR" ]; then
    (cd $HEX2BIN_DIR && CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" ${KWFLAGS_HEX2BIN} make)
    if [ $? -ne 0 ]; then echo "Failed to make hex2bin"; exit 1; fi
    (cd $HEX2BIN_DIR && CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" make install)
    if [ $? -ne 0 ]; then echo "Failed to make install hex2bin"; exit 2; fi
  fi
}

install_hex2bin
rm -rf dist-clean
mkdir dist-clean
cp -r $PREFIX dist-clean
