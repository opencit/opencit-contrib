#!/bin/bash
PREFIX=${PREFIX:-/opt/dcgcontrib}
TPM_QUOTE_TOOLS_URL=http://downloads.sourceforge.net/project/tpmquotetools/1.0.2/tpm-quote-tools-1.0.2.tar.gz
TPM_QUOTE_TOOLS=tpm-quote-tools-1.0.2

download_files() {
  if [ ! -f $TPM_QUOTE_TOOLS.tar.gz ]; then
    wget $TPM_QUOTE_TOOLS_URL
  fi
}

install_tpm_quote_tools() {
  mkdir -p $PREFIX
  TPM_QUOTE_TOOLS_FILE=`find ${TPM_QUOTE_TOOLS}*gz`
  echo "tpm-quote-tools: $TPM_QUOTE_TOOLS_FILE"
  if [ -n "$TPM_QUOTE_TOOLS_FILE" ] && [ -f "$TPM_QUOTE_TOOLS_FILE" ]; then
    rm -rf $TPM_QUOTE_TOOLS
    tar fxz $TPM_QUOTE_TOOLS_FILE
	(cd $TPM_QUOTE_TOOLS &&  ./configure --prefix=$PREFIX --with-openssl=$PREFIX && make && make install)
  fi
}

install_tpm_quote_tools_contrib() {
  #what it was before using PREFIX:  gcc -g -O0 -DLOCALEDIR='"/usr/share/locale"' -Itpm-tools-1.3.8 -Itpm-tools-1.3.8/include -o tpm_createkey tpm_createkey.c tpm-tools-1.3.8/lib/tpm_tspi.c tpm-tools-1.3.8/lib/tpm_utils.c tpm-tools-1.3.8/lib/tpm_log.c hex2bytea.c -lcrypto -ltspi 
  gcc -g -O0 -L$PREFIX/lib -DLOCALEDIR='"/usr/share/locale"' -Itpm-tools-1.3.8 -Itpm-tools-1.3.8/include -o tpm_createkey tpm_createkey.c tpm-tools-1.3.8/lib/tpm_tspi.c tpm-tools-1.3.8/lib/tpm_utils.c tpm-tools-1.3.8/lib/tpm_log.c hex2bytea.c -lcrypto -ltspi 
  gcc -g -O0 -L$PREFIX/lib -DLOCALEDIR='"/usr/share/locale"' -Itpm-tools-1.3.8 -Itpm-tools-1.3.8/include -o tpm_bindaeskey tpm_bindaeskey.c tpm-tools-1.3.8/lib/tpm_tspi.c tpm-tools-1.3.8/lib/tpm_utils.c tpm-tools-1.3.8/lib/tpm_log.c -lcrypto -ltspi 
  gcc -g -O0 -L$PREFIX/lib -DLOCALEDIR='"/usr/share/locale"' -Itpm-tools-1.3.8 -Itpm-tools-1.3.8/include -o tpm_unbindaeskey tpm_unbindaeskey.c tpm-tools-1.3.8/lib/tpm_tspi.c tpm-tools-1.3.8/lib/tpm_utils.c tpm-tools-1.3.8/lib/tpm_log.c hex2bytea.c -lcrypto -ltspi 
  gcc -g -O0 -L$PREFIX/lib -DLOCALEDIR='"/usr/share/locale"' -Itpm-tools-1.3.8 -Itpm-tools-1.3.8/include -o tpm_signdata  tpm_signdata.c tpm-tools-1.3.8/lib/tpm_tspi.c tpm-tools-1.3.8/lib/tpm_utils.c tpm-tools-1.3.8/lib/tpm_log.c hex2bytea.c -lcrypto -ltspi 
  mkdir -p $PREFIX/bin
  cp tpm_createkey tpm_bindaeskey tpm_unbindaeskey tpm_signdata $PREFIX/bin
}

( cd 1.0.2 && download_files && install_tpm_quote_tools && install_tpm_quote_tools_contrib )
