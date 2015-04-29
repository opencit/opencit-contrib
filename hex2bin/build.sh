#!/bin/bash
PREFIX=${PREFIX:-/opt/dcgcontrib}
VERSION=1.0
HEX2BIN_URL=https://github.com/jbuhacoff/hex2bin/archive/master.zip

HEX2BIN=hex2bin-master

download_files() {
  if [ ! -f $HEX2BIN.zip ]; then
    wget $HEX2BIN_URL -O $HEX2BIN.zip
  fi
}

install_hex2bin() {
  mkdir -p $PREFIX
  HEX2BIN_FILE=`find ${HEX2BIN}*zip`
  echo "hex2bin: $HEX2BIN"
  if [ -n "$HEX2BIN_FILE" ] && [ -f "$HEX2BIN_FILE" ]; then
    rm -rf $HEX2BIN
    unzip $HEX2BIN_FILE
    (cd $HEX2BIN && make && make install)
  fi
}

# look for /usr/local/bin/hex2bin, return 0 if found, 1 if not found
detect_hex2bin() {
  hex2bin_bin=`which hex2bin`
  if [ -n "$hex2bin_bin" ]; then return 0; fi
  return 1
}

( cd $VERSION && download_files && install_hex2bin )
