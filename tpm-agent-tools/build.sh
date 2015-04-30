#!/bin/bash
PREFIX=${PREFIX:-/opt/dcgcontrib}


install_tpm_agent_tools() {
  gcc -L $PREFIX/lib -o aikquote aikquote.c -ltspi
  gcc -L $PREFIX/lib -o aikqverify aikqverify.c -ltspi -lcrypto
  gcc -L $PREFIX/lib -o getcert getcert.c -ltspi
  gcc -L $PREFIX/lib -o getcert01 getcert01.c -ltspi
  mkdir -p $PREFIX
  cp aikquote aikqverify getcert getcert01 $PREFIX/bin
}

rm -rf target
mkdir target
cp src/* target/

( cd target && install_tpm_agent_tools )
