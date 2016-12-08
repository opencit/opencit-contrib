/*
 * hex2bin - converts data in hexadecimal form to binary form
 *
 * Copyright (C) 2013-2016 Jonathan Buhacoff <jonathan@buhacoff.net>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software. 
 *  
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

/*
 * Input: hexadecimal character in the range 0..9 or A..F case-insensitive
 * Output: decimal value of input in the range 0..15 
 *         or -1 if the input was not a valid hexadecimal character
 */
int hex2int(const char c)
{
	//if( !isxdigit(c) ) { return -1; }
	switch(c) {
		case '0': return 0;
		case '1': return 1;
		case '2': return 2;
		case '3': return 3;
		case '4': return 4;
		case '5': return 5;
		case '6': return 6;
		case '7': return 7;
		case '8': return 8;
		case '9': return 9;
		case 'A': case 'a': return 10;
		case 'B': case 'b': return 11;
		case 'C': case 'c': return 12;
		case 'D': case 'd': return 13;
		case 'E': case 'e': return 14;
		case 'F': case 'f': return 15;
		default: return -1;
    }
}

/*
 * returns 0 on success, 1 on failure
 */
int hexfile2binfile(FILE *in, FILE *out) {
    int b; // one byte buffer
	int h1, h2; // next two hex digits
	int c1, c2; // integer values of next two hex digits
	for(;;) {
		h1 = fgetc(in);
		h2 = fgetc(in);
		if( feof(in) ) { break; }
		c1 = hex2int( h1 );
		c2 = hex2int( h2 );
		if( c1 == -1 || c2 == -1 ) { fprintf(stderr, "non-hex input\n"); return 1; }
		b = (c1*16)+c2;
		fputc(b, out);
	}
	return 0;
}

/*
 * arg must be a null-terminated string comprised of pairs of hex digits
 * where each pair represents a single byte; the pairs must not be separated
 * by any whitespace or punctuation
 * returns 0 on success, 1 on failure
 */
int hexarg2binfile(char *arg, FILE *out) {
	int i; // loop index
    int b; // one byte buffer
	int c1, c2; // integer values of next two hex digits
	for(i=0; arg[i] != '\0' && arg[i+1] != '\0';i+=2) {
		c1 = hex2int( arg[i] );
		c2 = hex2int( arg[i+1] );
		if( c1 == -1 || c2 == -1 ) { fprintf(stderr, "non-hex input\n"); return 1; }
		b = (c1*16)+c2;
		fputc(b, out);
	}
	return 0;
}

int help() {
	printf("Usage:\n");
	printf("stdin to stdout: echo 00 | hex2bin > 0.bin\n");
	printf("arg to stdout: hex2bin 00 > 0.bin\n");
	printf("stdin to file: echo 00 | hex2bin -stdin 0.bin\n");
	printf("arg to file: hex2bin 00 0.bin\n");
	printf("\n");
	printf("Input must contain only hex characters.\n");
	return -1;
}

int main(int argc, char **argv) {
    int err = 0;
    if(argc == 1) {
		return hexfile2binfile(stdin, stdout);
	}
	if(argc == 2) {
		if( strncmp(argv[1],"-h",strlen("-h")) == 0 || strncmp(argv[1],"--help",strlen("--help")) == 0 ) {
			return help();
		}
		else {
			return hexarg2binfile(argv[1], stdout);
		}
	}
	if(argc == 3) {
		// arg or stdin to outfile
		FILE* outfile = fopen(argv[2],"w");
		if( strncmp(argv[1],"-stdin",strlen("-stdin")) == 0 ) {
			err = hexfile2binfile(stdin, outfile);
		}
		else {
			err = hexarg2binfile(argv[1], outfile);
		}
		fclose(outfile);
		return err;
	}
	if(argc > 3) {
		return help();
    }
}
/* Notes:
 * Would be nice to add an option in the future to support hex files with
 * comment lines starting with #, and to ignore blank lines and newline characters.
 */
