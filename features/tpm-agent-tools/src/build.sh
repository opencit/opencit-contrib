#!/bin/bash
export PREFIX=${PREFIX:-${HOME:-/tmp}/local}
export LINUX_TARGET=${LINUX_TARGET:-generic}


install_tpm_agent_tools() {
  #gcc -I$PREFIX/include -L$PREFIX/lib -o aikquote aikquote.c -ltspi
  #gcc -I$PREFIX/include -L$PREFIX/lib -o aikqverify aikqverify.c -ltspi -lcrypto
  #gcc -I$PREFIX/include -L$PREFIX/lib -o getcert getcert.c -ltspi
  #gcc -I$PREFIX/include -L$PREFIX/lib -o getcert01 getcert01.c -ltspi
  #mkdir -p $PREFIX
  #cp aikquote aikqverify getcert getcert01 $PREFIX/bin
  CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" make && make install
}

install_tpm_agent_tools
