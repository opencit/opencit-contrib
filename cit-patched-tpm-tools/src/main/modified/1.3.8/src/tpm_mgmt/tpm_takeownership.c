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

#include "tpm_tspi.h"
#include "tpm_utils.h"

static void help(const char* aCmd)
{
	logCmdHelp(aCmd);
	logUnicodeCmdOption();
	logCmdOption("-o, --owner", _("Set owner secret"));
	logCmdOption("-s, --srk", _("Set the SRK secret"));
	logCmdOption("-t, --use-env",
		     _("TPM owner secret and NVRAM area secret are in environment variables "
			   "whose names are given by -o and -a, respectively"));
	logCmdOption("-x, --use-hex", _("Use hex encoding for owner secret and SRK secret"));
	logCmdOption("-y, --owner-well-known", _("Set the owner secret to all zeros (20 bytes of zeros)."));
	logCmdOption("-z, --srk-well-known", _("Set the SRK secret to all zeros (20 bytes of zeros)."));
}

static BOOL ownerWellKnown = FALSE;
static BOOL srkWellKnown = FALSE;
static BOOL askOwnerPass;
static BOOL askSrkPass;
static BOOL decodeHexPassword = FALSE;
static BOOL useEnvironment = FALSE;
TSS_HCONTEXT hContext = 0;
static const char *ownerpass = NULL;
static const char *srkpass = NULL;
static const char *ownerpassEnv = NULL;
static const char *srkpassEnv = NULL;

static int parse(const int aOpt, const char *aArg)
{

	switch (aOpt) {
	case 's':
		srkpass = aArg;
		if (!srkpass)
			askSrkPass = TRUE;
		else
			askSrkPass = FALSE;
		srkWellKnown = FALSE;
		break;
	case 'o':
		ownerpass = aArg;
		if (!ownerpass)
			askOwnerPass = TRUE;
		else
			askOwnerPass = FALSE;
		ownerWellKnown = FALSE;
		break;
	case 't':
		useEnvironment = TRUE;
		break;
	case 'x':
		decodeHexPassword = TRUE;
		break;
	case 'y':
		ownerWellKnown = TRUE;
		ownerpass = NULL;
		askOwnerPass = FALSE;
		break;
	case 'z':
		srkWellKnown = TRUE;
		srkpass = NULL;
		askSrkPass = FALSE;
		break;
	default:
		return -1;
	}
	return 0;
}

static inline TSS_RESULT tpmTakeOwnership(TSS_HTPM a_hTpm, TSS_HKEY a_hSrk)
{

	TSS_RESULT result =
	    Tspi_TPM_TakeOwnership(a_hTpm, a_hSrk, NULL_HKEY);
	tspiResult("Tspi_TPM_TakeOwnership", result);

	return result;
}

int main(int argc, char **argv)
{

	int tpm_len = 0, srk_len = 0;
	TSS_HTPM hTpm;
	TSS_HKEY hSrk;
	TSS_FLAG fSrkAttrs;
	TSS_HPOLICY hTpmPolicy, hSrkPolicy;
	char *szTpmPasswd = NULL;
	char *szSrkPasswd = NULL;
	BYTE* pTpmPasswd = NULL;
	BYTE* pSrkPasswd = NULL;
	int iTpmPasswdLen, iSrkPasswdLen;
	int iRc = -1;
	BYTE well_known_secret[] = TSS_WELL_KNOWN_SECRET;
	struct option opts[] = {
	{"owner"   , required_argument, NULL, 'o'},
	{"srk"     , required_argument, NULL, 's'},
	{"use-env",          no_argument, NULL, 't'},
	{"use-hex",          no_argument, NULL, 'x'},
	{"owner-well-known", no_argument, NULL, 'y'},
	{"srk-well-known", no_argument, NULL, 'z'},
	};

	initIntlSys();

	if (genericOptHandler
	    (argc, argv, "o:s:txyz", opts, sizeof(opts) / sizeof(struct option),
	     parse, help) != 0)
		goto out;

	if (contextCreate(&hContext) != TSS_SUCCESS)
		goto out;

	if (askOwnerPass) {
		// Prompt for owner password
		szTpmPasswd = GETPASSWD(_("Enter owner password: "), &tpm_len, TRUE);
		if (!szTpmPasswd)
			goto out;
		ownerpass = szTpmPasswd;
	}

	if (askSrkPass) {
		// Prompt for srk password
		szSrkPasswd = GETPASSWD(_("Enter SRK password: "), &srk_len, TRUE);
		if (!szSrkPasswd)
			goto out;
		srkpass = szSrkPasswd;
	}

	if (contextConnect(hContext) != TSS_SUCCESS)
		goto out_close;

	if (contextGetTpm(hContext, &hTpm) != TSS_SUCCESS)
		goto out_close;

	if (policyGet(hTpm, &hTpmPolicy) != TSS_SUCCESS)
		goto out_close;

	if (ownerpass && !askOwnerPass && useEnvironment) {
		ownerpassEnv = ownerpass;
		ownerpass = getenv(ownerpassEnv);
		if (!ownerpass) {
			logError(_("%s is not defined\n"), ownerpassEnv);
			goto out_close;
		}
	}
		
	if (ownerWellKnown) {
		tpm_len = TCPA_SHA1_160_HASH_LEN;
		if (policySetSecret(hTpmPolicy, tpm_len, well_known_secret) != TSS_SUCCESS)
			goto out_obj_close;
	} else if( decodeHexPassword ) {
				if(ownerpass == NULL) {
					logMsg(_("NULL TPM owner secret\n"));
					goto out_close;
				}
				if( hex2bytea(ownerpass, &pTpmPasswd, &iTpmPasswdLen) != 0 ) {
					logError(_("Invalid hex TPM owner secret\n"));
					goto out_close;
				}
				if( Tspi_Policy_SetSecret(hTpmPolicy, TSS_SECRET_MODE_PLAIN, iTpmPasswdLen,
							pTpmPasswd) != TSS_SUCCESS)
					goto out_close;
        } else {
            if (ownerpass == NULL) {
                logMsg(_("NULL TPM owner secret\n"));
                goto out_close;
            }
            if (tpm_len <= 0)
                tpm_len = strlen(ownerpass);
            if (policySetSecret(hTpmPolicy, tpm_len, (BYTE *) ownerpass) != TSS_SUCCESS)
                goto out_close;

        }

	fSrkAttrs = TSS_KEY_TSP_SRK | TSS_KEY_AUTHORIZATION;

	if (contextCreateObject
	    (hContext, TSS_OBJECT_TYPE_RSAKEY, fSrkAttrs,
	     &hSrk) != TSS_SUCCESS)
		goto out_close;

	if (policyGet(hSrk, &hSrkPolicy) != TSS_SUCCESS)
		goto out_obj_close;

	if (srkpass && !askSrkPass && useEnvironment) {
		srkpassEnv = srkpass;
		srkpass = getenv(srkpassEnv);
		if (!srkpass) {
			logError(_("%s is not defined\n"), srkpassEnv);
			goto out_close;
		}
	}
		
	if (srkWellKnown) {
		srk_len = TCPA_SHA1_160_HASH_LEN;
		if (policySetSecret(hSrkPolicy, srk_len, well_known_secret) != TSS_SUCCESS)
			goto out_obj_close;
	} else {
			if( decodeHexPassword ) {
				if(srkpass == NULL) {
					logMsg(_("NULL SRK secret\n"));
					goto out_close;
				}
				if( hex2bytea(srkpass, &pSrkPasswd, &iSrkPasswdLen) != 0 ) {
					logError(_("Invalid hex SRK secret\n"));
					goto out_close;
				}
				if( Tspi_Policy_SetSecret(hSrkPolicy, TSS_SECRET_MODE_PLAIN, iSrkPasswdLen,
							pSrkPasswd) != TSS_SUCCESS)
					goto out_close;
			}
			else {
			if(srkpass == NULL) {
                                logMsg(_("NULL SRK secret\n"));
                                goto out_close;
                        }
			if( srk_len <= 0 )
				srk_len = strlen(srkpass);
		if (policySetSecret(hSrkPolicy, srk_len, (BYTE *)srkpass) != TSS_SUCCESS)
			goto out_obj_close;
			
			}
	}

	if (tpmTakeOwnership(hTpm, hSrk) != TSS_SUCCESS)
		goto out_obj_close;

	iRc = 0;
	logSuccess(argv[0]);

	out_obj_close:
		contextCloseObject(hContext, hSrk);

	out_close:
		contextClose(hContext);

	out:
		if (szTpmPasswd)
			shredPasswd(szTpmPasswd);

		if (szSrkPasswd)
			shredPasswd(szSrkPasswd);

		if( pTpmPasswd )
			shredByteArray(pTpmPasswd, iTpmPasswdLen);
			
		if( pSrkPasswd )
			shredByteArray(pSrkPasswd, iSrkPasswdLen);
			
	return iRc;
}
