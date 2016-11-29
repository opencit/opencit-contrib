#!/bin/bash
# PREFIX must be an absolute path
# PREFIX must be exported for "make" subshell
export PREFIX=${PREFIX:-/opt/mtwilson/share/hex2bin}
export LINUX_TARGET=${LINUX_TARGET:-generic}
VERSION=1.0
HEX2BIN_URL=https://github.com/jbuhacoff/hex2bin/archive/master.zip
HEX2BIN=hex2bin-master

download_files() {
  if [ ! -f hex2bin-1.0.zip ]; then
    wget $HEX2BIN_URL -O hex2bin-1.0.zip
	mvn install:install-file -Dfile=hex2bin-1.0.zip -DgroupId=com.github.hex2bin -DartifactId=hex2bin -Dversion=1.0 -Dpackaging=zip -Dclassifier=sources
  fi
}

install_hex2bin() {
  echo "PREFIX=$PREFIX"
  mkdir -p $PREFIX
  HEX2BIN_FILE=`find hex2bin*zip`
  echo "hex2bin zip: $HEX2BIN_FILE"
  echo "hex2bin: $HEX2BIN"
  if [ -n "$HEX2BIN_FILE" ] && [ -f "$HEX2BIN_FILE" ]; then
    rm -rf $HEX2BIN
    unzip $HEX2BIN_FILE
    cp $HEX2BIN/Makefile $HEX2BIN/Makefile.bak
    patch -p0 < 1.0/hex2bin_Makefile.patch
    (cd $HEX2BIN && make && make install)
  fi
}

install_hex2bin
