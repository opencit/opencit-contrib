# LDFLAGS = -L$PREFIX/lib
# CFLAGS = -I$PREFIX/include
# compiling the main class file NIARL_TPM_ModuleV2.cpp produces a lot of warnings

all: NIARL_TPM_Module

NIARL_TPM_Module:
	g++ -g -O3 $(CFLAGS) -c -o NIARL_TPM_ModuleV2.o NIARL_TPM_ModuleV2.cpp
	g++ -g -O3 $(CFLAGS) -c -o NIARL_Util_ByteBlob.o NIARL_Util_ByteBlob.cpp
	g++ -g -O3 $(CFLAGS) -c -o NIARL_Util_Mask.o NIARL_Util_Mask.cpp
	g++ -g -O3 $(CFLAGS) -c -o main.o main.cpp
	g++ -g $(LDFLAGS) $(CFLAGS) -o"NIARL_TPM_Module" NIARL_TPM_ModuleV2.o NIARL_Util_ByteBlob.o NIARL_Util_Mask.o main.o -ltspi

install: NIARL_TPM_Module
	mkdir -p $(PREFIX)/bin
	cp NIARL_TPM_Module $(PREFIX)/bin
