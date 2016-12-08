# LDFLAGS = -L$PREFIX/lib
# CFLAGS = -I$PREFIX/include
CC=gcc
CWDFLAGS=-fstack-protector -fPIE -fPIC -O2 -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security -z noexecstack -z relro -z now -pie

all: aikquote aikqverify getcert getcert01 extend_sha1

aikquote:
	$(CC) $(LDFLAGS) $(CFLAGS) $(CWDFLAGS) -o aikquote aikquote.c -ltspi

aikqverify:
	$(CC) $(LDFLAGS) $(CFLAGS) $(CWDFLAGS) -o aikqverify aikqverify.c -ltspi -lcrypto

aikqverify2:
	$(CC) $(LDFLAGS) $(CFLAGS) $(CWDFLAGS) -o aikqverify2 aikqverify2.c -lcrypto

aikqverifywin:
	$(CC) $(LDFLAGS) $(CFLAGS) $(CWDFLAGS) -o aikqverifywin aikqverifywin.c -lcrypto

aikqverifywin2:
	$(CC) $(LDFLAGS) $(CFLAGS) $(CWDFLAGS) -o aikqverifywin2 aikqverifywin2.c -lcrypto

getcert:
	$(CC) $(LDFLAGS) $(CFLAGS) $(CWDFLAGS) -o getcert getcert.c -ltspi

getcert01:
	$(CC) $(LDFLAGS) $(CFLAGS) $(CWDFLAGS) -o getcert01 getcert01.c -ltspi

extend_sha1:
	$(CC) $(LDFLAGS) $(CFLAGS) $(CWDFLAGS) -o extend_sha1 extend_sha1.c -lcrypto

clean:
	rm -f aikquote aikqverify aikqverify2 aikqverifywin aikqverifywin2 getcert getcert01 extend_sha1

install: aikquote aikqverify aikqverify2 aikqverifywin aikqverifywin2 getcert getcert01 extend_sha1
	mkdir -p $(PREFIX)/bin
	cp aikquote aikqverify aikqverify2 aikqverifywin aikqverifywin2 getcert getcert01 extend_sha1 $(PREFIX)/bin
