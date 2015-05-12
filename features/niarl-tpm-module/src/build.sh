#!/bin/bash
export PREFIX=${PREFIX:-${HOME:-/tmp}/local}
export LINUX_TARGET=${LINUX_TARGET:-generic}

install_niarl_tpm_module() {
  ## compiling the main class file produces a lot of warnings
  #g++ -g -O3 -I$PREFIX/include -c -o NIARL_TPM_ModuleV2.o NIARL_TPM_ModuleV2.cpp
  ## no warnings on the rest of these
  #g++ -g -O3 -I$PREFIX/include -c -o NIARL_Util_ByteBlob.o NIARL_Util_ByteBlob.cpp
  #g++ -g -O3 -I$PREFIX/include -c -o NIARL_Util_Mask.o NIARL_Util_Mask.cpp
  #g++ -g -O3 -I$PREFIX/include -c -o main.o main.cpp
  #g++ -g -I$PREFIX/include -L$PREFIX/lib -o"NIARL_TPM_Module" NIARL_TPM_ModuleV2.o NIARL_Util_ByteBlob.o NIARL_Util_Mask.o main.o -ltspi
  #mkdir -p $PREFIX/bin
  #cp NIARL_TPM_Module $PREFIX/bin
  CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" make && make install
}

( cd c++ && install_niarl_tpm_module )
