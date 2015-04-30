#!/bin/bash
PREFIX=${PREFIX:-/opt/dcgcontrib}

install_niarl_tpm_module() {
  # compiling the main class file produces a lot of warnings
  g++ -g -O3 -c -o NIARL_TPM_ModuleV2.o NIARL_TPM_ModuleV2.cpp
  # no warnings on the rest of these
  g++ -g -O3 -c -o NIARL_Util_ByteBlob.o NIARL_Util_ByteBlob.cpp
  g++ -g -O3 -c -o NIARL_Util_Mask.o NIARL_Util_Mask.cpp
  g++ -g -O3 -c -o main.o main.cpp
  g++ -g -L$PREFIX/lib -o"NIARL_TPM_Module" NIARL_TPM_ModuleV2.o NIARL_Util_ByteBlob.o NIARL_Util_Mask.o main.o -ltspi
  mkdir -p $PREFIX/bin
  cp NIARL_TPM_Module $PREFIX/bin
}

rm -rf target
mkdir target
cp src/* target/

( cd target && install_niarl_tpm_module )
