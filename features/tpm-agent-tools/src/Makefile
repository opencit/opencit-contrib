# LDFLAGS = -L$PREFIX/lib
# CFLAGS = -I$PREFIX/include

all: aikquote aikqverify getcert getcert01

aikquote:
	gcc $(LDFLAGS) $(CFLAGS) -o aikquote aikquote.c -ltspi

aikqverify:
	gcc $(LDFLAGS) $(CFLAGS) -o aikqverify aikqverify.c -ltspi -lcrypto

getcert:
	gcc $(LDFLAGS) $(CFLAGS) -o getcert getcert.c -ltspi

getcert01:
	gcc $(LDFLAGS) $(CFLAGS) -o getcert01 getcert01.c -ltspi

install: aikquote aikqverify getcert getcert01
	mkdir -p $(PREFIX)/bin
	cp aikquote aikqverify getcert getcert01 $(PREFIX)/bin
