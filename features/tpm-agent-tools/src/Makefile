# LDFLAGS = -L$PREFIX/lib
# CFLAGS = -I$PREFIX/include

all: aikquote aikqverify getcert getcert01 extend_sha1

aikquote:
	gcc $(LDFLAGS) $(CFLAGS) -o aikquote aikquote.c -ltspi

aikqverify:
	gcc $(LDFLAGS) $(CFLAGS) -o aikqverify aikqverify.c -ltspi -lcrypto

getcert:
	gcc $(LDFLAGS) $(CFLAGS) -o getcert getcert.c -ltspi

getcert01:
	gcc $(LDFLAGS) $(CFLAGS) -o getcert01 getcert01.c -ltspi

extend_sha1:
	gcc $(LDFLAGS) $(CFLAGS) -o extend_sha1 extend_sha1.c -lcrypto

install: aikquote aikqverify getcert getcert01 extend_sha1
	mkdir -p $(PREFIX)/bin
	cp aikquote aikqverify getcert getcert01 extend_sha1 $(PREFIX)/bin
