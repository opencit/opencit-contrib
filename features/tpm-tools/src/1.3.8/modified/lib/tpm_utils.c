/*
 * The Initial Developer of the Original Code is International
 * Business Machines Corporation. Portions created by IBM
 * Corporation are Copyright (C) 2005 International Business
 * Machines Corporation. All Rights Reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the Common Public License as published by
 * IBM Corporation; either version 1 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * Common Public License for more details.
 *
 * You should have received a copy of the Common Public License
 * along with this program; if not, a copy can be viewed at
 * http://www.opensource.org/licenses/cpl1.0.php.
 */

#include "config.h"
#include <unistd.h>
#include <stdlib.h>
#include <trousers/tss.h>
#include <trousers/trousers.h>
#include <ctype.h>

#include "tpm_tspi.h"
#include "tpm_utils.h"

BOOL useUnicode = FALSE;

int hex2int(const char c);


static const struct option sGenLongOpts[] = {
	{ "help", no_argument, NULL, 'h' },
	{ "version", no_argument, NULL, 'v' },
	{ "log", required_argument, NULL, 'l' },
	{ "unicode", no_argument, NULL, 'u' },
};

static const char *pszGenShortOpts = "hvl:u";

void initIntlSys( ) {

	setlocale( LC_ALL, "" );
	bindtextdomain( PACKAGE, LOCALEDIR );
	textdomain( PACKAGE );
}

int
genericOptHandler( int a_iNumArgs, char **a_pszArgs,
		   const char *a_pszShortOpts,
		   struct option *a_sLongOpts, int a_iNumOpts,
		   CmdOptParser a_tCmdOptParser, CmdHelpFunction a_tCmdHelpFunction ) {

	CmdHelpFunction  tCmdHelp = ( a_tCmdHelpFunction ) ? a_tCmdHelpFunction
							   : logCmdHelp;

	char  szShortOpts[strlen( pszGenShortOpts )
			  + ( ( a_pszShortOpts == NULL ) ? 0 : strlen( a_pszShortOpts ) )
			  + 1];

	int            iNumGenLongOpts = sizeof( sGenLongOpts ) / sizeof( struct option );
	struct option  sLongOpts[iNumGenLongOpts + a_iNumOpts + 1];

	int  iOpt;
	int  rc;

	strcpy( szShortOpts, pszGenShortOpts);
	if ( a_pszShortOpts )
		strcat( szShortOpts, a_pszShortOpts );

	memset( sLongOpts, 0, sizeof( sLongOpts ) );
	memcpy( sLongOpts, sGenLongOpts, sizeof( sGenLongOpts ) );
	if ( a_sLongOpts ) {
		memcpy( sLongOpts + iNumGenLongOpts,
			a_sLongOpts,
			a_iNumOpts * sizeof( struct option ) );
	}

	while ( ( iOpt = getopt_long( a_iNumArgs, a_pszArgs,
					szShortOpts, sLongOpts, NULL ) ) != -1 ) {

		switch ( iOpt ) {
			case 'h':
				tCmdHelp( a_pszArgs[0] );
				return -1;

			case 'v':
				logMsg( _("%s version: %s\n"), a_pszArgs[0], CMD_VERSION );
				return -1;

			case 'l':
				if ( !optarg ) {
					tCmdHelp( a_pszArgs[0] );
					return -1;
				}

				if ( strcmp( optarg, LOG_NONE ) == 0 )
					iLogLevel = LOG_LEVEL_NONE;
				else if ( strcmp( optarg, LOG_ERROR ) == 0 )
					iLogLevel = LOG_LEVEL_ERROR;
				else if ( strcmp( optarg, LOG_INFO ) == 0 )
					iLogLevel = LOG_LEVEL_INFO;
				else if ( strcmp( optarg, LOG_DEBUG ) == 0 )
					iLogLevel = LOG_LEVEL_DEBUG;
				else {
					logMsg( _("Valid log levels are: %s, %s, %s, %s\n"),
						LOG_NONE,
						LOG_ERROR,
						LOG_INFO,
						LOG_DEBUG );
					tCmdHelp( a_pszArgs[0] );
					return -1;
				}
				break;
			case 'u':
				useUnicode = TRUE;
				break;
			case '?':
				tCmdHelp( a_pszArgs[0] );
				return -1;

			default:
				if ( !a_tCmdOptParser )
					return -1;

				rc = a_tCmdOptParser( iOpt, optarg );
				if ( rc != 0 )
					return rc;
				break;
		}
	}

	return 0;
}

/*
 * This function should be called when you are done with a password
 * the above getPasswd function to properly clean up.
 */
void shredPasswd( char *a_pszPasswd ) {

	if ( a_pszPasswd ) {
		memset( a_pszPasswd, 0, strlen( a_pszPasswd ) );
		free( a_pszPasswd );
	}
}

void shredByteArray( BYTE *a_pSecret, int iSecretLen ) {

	if ( a_pSecret ) {
		memset( a_pSecret, 0, iSecretLen );
		free( a_pSecret );
	}
}

/*
 * You must free the memory passed back to you when you are finished.
 * Loop will always terminate by the second pass.
 * Safest use of getpass is to zero the memory as soon as possible.
 */
char *getPlainPasswd(const char *a_pszPrompt, BOOL a_bConfirm) {
	int len;
	return _getPasswd(a_pszPrompt, &len, a_bConfirm, FALSE);
}

#ifndef TSS_LIB_IS_12
char *getPasswd(const char *a_pszPrompt, int* a_iLen, 
		BOOL a_bConfirm) {
	return _getPasswd( a_pszPrompt, a_iLen, a_bConfirm, useUnicode);
}
#endif
char *_getPasswd(const char *a_pszPrompt, int* a_iLen, 
		BOOL a_bConfirm, BOOL a_bUseUnicode) {

	char *pszPrompt = (char *)a_pszPrompt;
	char *pszPasswd = NULL;
	char *pszRetPasswd = NULL;

	do {
		// Get password value from user - this is a static buffer
		// and should never be freed
		pszPasswd = getpass( pszPrompt );
		if (!pszPasswd && pszRetPasswd) {
			shredPasswd( pszRetPasswd );
			return NULL;
		}

		// If this is confirmation pass check for match
		if ( pszRetPasswd ) {
			// Matched work complete
			if ( strcmp( pszPasswd, pszRetPasswd ) == 0)
				goto out;

			// No match clean-up
			logMsg( _("Passwords didn't match\n") );

			// pszPasswd will be cleaned up at out label
			shredPasswd( pszRetPasswd );
			pszRetPasswd = NULL;
			goto out;
		}

		// Save this passwd for next pass and/or return val
		pszRetPasswd = strdup( pszPasswd );
		if ( !pszRetPasswd )
			goto out;

		pszPrompt = _("Confirm password: ");
	} while (a_bConfirm);

out:
	if (pszRetPasswd) {
		*a_iLen = strlen(pszRetPasswd);

		if (a_bUseUnicode) {
			shredPasswd(pszRetPasswd);
			pszRetPasswd = (char *)Trspi_Native_To_UNICODE((BYTE *)pszPasswd, (unsigned int *)a_iLen);
		}
	}

	// pszPasswd is a static buffer, just clear it
	if ( pszPasswd )
		memset( pszPasswd, 0, strlen( pszPasswd ) );

	return pszRetPasswd;
}

/*
 * You must free the memory passed back to you when you are finished.
 */
char *getReply( const char *a_pszPrompt, int a_iMaxLen ) {

	char *pszReply  = NULL;
	int   iReplyLen = a_iMaxLen + 2; // Room for newline and trailing zero

	if ( iReplyLen <= 0 )
		goto out;

	pszReply = (char *)calloc( iReplyLen, 1 );
	if ( !pszReply )
		goto out;

	logMsg( "%s", a_pszPrompt );
	pszReply = fgets( pszReply, iReplyLen, stdin );
	if ( !pszReply )
		goto out;

	// Be certain that a complete line was read
	if ( ( pszReply[ a_iMaxLen ] != '\n' ) && ( pszReply[ a_iMaxLen ] != '\0' ) ) {
		free( pszReply );
		pszReply = NULL;
		goto out;
	}

	for ( iReplyLen -= 1; iReplyLen >= 0; iReplyLen-- ) {
		if ( pszReply[ iReplyLen ] == '\0' )
			continue;

		if ( pszReply[ iReplyLen ] == '\n' )
			pszReply[ iReplyLen ] = '\0';
		break;
	}

out:
	return pszReply;
}


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
 * You must free the memory allocated to a_pDecoded when you are done with it.
 * Returns 0 for success, non-zero for failure.
 */

int hex2bytea( const char *a_pszHex, BYTE **a_pDecoded, int *a_iDecodedLen ) {
        BYTE *pDecoded;
        int iDecodedLen, iByte, i;
        int iHexLen = strlen(a_pszHex);
        if( iHexLen % 2 != 0 ) {
                *a_pDecoded = NULL;
                *a_iDecodedLen = 0;
                return 1; // invalid length for hex
        }
        iDecodedLen = iHexLen / 2;
        pDecoded = malloc( sizeof(char) * iDecodedLen );
        int hex1;
        int hex2;
        int pDecoded_index=0;
        for(i=0; i<iHexLen-1; i=i+2) {

                hex1 = hex2int(a_pszHex[i]);
                hex2 = hex2int(a_pszHex[i+1]);

                if(hex1 == -1 || hex2 == -1) {
                        free(pDecoded);
                        *a_pDecoded = NULL;
                        *a_iDecodedLen = 0;
                        return 2; // invalid hex digit
                }

                iByte = (hex1*16) + hex2;

                pDecoded[pDecoded_index++] = iByte & 0xFF;
        }
        *a_pDecoded = pDecoded;
        *a_iDecodedLen = iDecodedLen;
        return 0;
}




