# LDFLAGS = -L$PREFIX/lib
# CFLAGS = -I$PREFIX/include
TPM_TOOLS_SRC ?= tpm-tools-1.3.8
CFLAGS += -g -O0 -DLOCALEDIR='"/usr/share/locale"'
CFLAGS += -I$(TPM_TOOLS_SRC) -I$(TPM_TOOLS_SRC)/include
TPM_TOOLS_SRC_FILES = $(TPM_TOOLS_SRC)/lib/tpm_tspi.c $(TPM_TOOLS_SRC)/lib/tpm_utils.c $(TPM_TOOLS_SRC)/lib/tpm_log.c

all: tpm_createkey tpm_bindaeskey tpm_unbindaeskey tpm_signdata

tpm_createkey:
	gcc $(LDFLAGS) $(CFLAGS) -o tpm_createkey tpm_createkey.c $(TPM_TOOLS_SRC_FILES) hex2bytea.c -lcrypto -ltspi 

tpm_bindaeskey:
	gcc $(LDFLAGS) $(CFLAGS) -o tpm_bindaeskey tpm_bindaeskey.c $(TPM_TOOLS_SRC_FILES) -lcrypto -ltspi 

tpm_unbindaeskey:
	gcc $(LDFLAGS) $(CFLAGS) -o tpm_unbindaeskey tpm_unbindaeskey.c $(TPM_TOOLS_SRC_FILES) hex2bytea.c -lcrypto -ltspi 

tpm_signdata:
	gcc $(LDFLAGS) $(CFLAGS) -o tpm_signdata  tpm_signdata.c $(TPM_TOOLS_SRC_FILES) hex2bytea.c -lcrypto -ltspi 

install: tpm_createkey tpm_bindaeskey tpm_unbindaeskey tpm_signdata
	mkdir -p $(PREFIX)/bin
	cp tpm_createkey tpm_bindaeskey tpm_unbindaeskey tpm_signdata $(PREFIX)/bin
