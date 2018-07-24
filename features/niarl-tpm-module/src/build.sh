#!/bin/bash
export PREFIX=${PREFIX:-/opt/mtwilson/share/niarl}
export OPENSSL=${OPENSSL:-/opt/mtwilson/share/openssl}
export TROUSERS=${TROUSERS:-/opt/mtwilson/share/trousers}
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
  (cd c++ && CFLAGS="-I$OPENSSL/include -I$TROUSERS/include" LDFLAGS="-L$OPENSSL/lib -L$TROUSERS/lib" ${KWFLAGS_NIARL} make)
  if [ $? -ne 0 ]; then echo "Failed to make NIARL"; exit 1; fi
  (cd c++ && PREFIX=$PREFIX make install)
  if [ $? -ne 0 ]; then echo "Failed to make install NIARL"; exit 2; fi
}

install_niarl_tpm_module
rm -rf dist-clean
mkdir dist-clean
cp -r $PREFIX dist-clean
