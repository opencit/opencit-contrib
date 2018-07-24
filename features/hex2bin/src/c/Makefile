PREFIX ?= /usr/local
CFLAGS=-fstack-protector-strong -fPIE -fPIC -O2 -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security
LDFLAGS=-z noexecstack -z relro -z now -pie

hex2bin: hex2bin.c
		gcc $(CFLAGS) -o hex2bin hex2bin.c $(LDFLAGS)

clean:
		rm -f hex2bin

install:
		chmod +x hex2bin
		mkdir -p $(PREFIX)/bin
		cp hex2bin $(PREFIX)/bin

