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

static const char *szTpmPasswdInput = NULL;
static BOOL decodeHexPassword = FALSE;
static BOOL useEnvironment = FALSE;
static BOOL isTpmPasswdInputRequired = FALSE;
static BOOL isWellKnown = FALSE;
TSS_HCONTEXT hContext = 0;

static int parse(const int aOpt, const char *aArg)
{

	switch (aOpt) {
	case 'o':
		szTpmPasswdInput = aArg;
		if(!szTpmPasswdInput)
			isTpmPasswdInputRequired = TRUE;
		break;
	case 't':
		useEnvironment = TRUE;
		break;
	case 'x':
		decodeHexPassword = TRUE;
		break;
	case 'z':
		logDebug(_("Using TSS_WELL_KNOWN_SECRET to authorize the TPM command\n"));
		isWellKnown = TRUE;
		break;
	default:
		return -1;
	}
	return 0;
}
static void help(const char* aCmd)
{
	logCmdHelp(aCmd);
	logUnicodeCmdOption();
	logCmdOption("-o, --owner", _("Set owner secret"));
	logCmdOption("-t, --use-env",
		     _("TPM owner secret is in an environment variable "
			   "whose name is given by -o"));
	logCmdOption("-x, --use-hex", _("Use hex encoding for owner secret and SRK secret"));
	logCmdOption("-z, --well-known",
		     _("Use 20 bytes of zeros (TSS_WELL_KNOWN_SECRET) as the TPM secret authorization data"));
}

int main(int argc, char **argv)
{

	char *szTpmPasswd = NULL;
	int pswd_len; // for szTpmPasswd
	BYTE* pTpmPasswdBytes = NULL;
	int iTpmPasswdBytesLen; // for pTpmPasswdBytes
	TSS_RESULT tResult;
	TSS_HTPM hTpm;
	TSS_HKEY hEk;
	TSS_HPOLICY hTpmPolicy;
	int iRc = -1;
	struct option hOpts[] = {
			{"owner"   , optional_argument, NULL, 'o'},
			{"use-env",          no_argument, NULL, 't'},
			{"use-hex",          no_argument, NULL, 'x'},
			{"well-known", no_argument, NULL, 'z'},
	};
	BYTE well_known[] = TSS_WELL_KNOWN_SECRET;

        initIntlSys();

	if (genericOptHandler
		    (argc, argv, "o::txz", hOpts,
		     sizeof(hOpts) / sizeof(struct option), parse, help) != 0)
		goto out;

	if (contextCreate(&hContext) != TSS_SUCCESS)
		goto out;

	if (contextConnect(hContext) != TSS_SUCCESS)
		goto out_close;

	if (contextGetTpm(hContext, &hTpm) != TSS_SUCCESS)
		goto out_close;

	if( isWellKnown ) {
		szTpmPasswd = (char *)well_known;
		pswd_len = sizeof(well_known);
	}
	else if( szTpmPasswdInput && useEnvironment ) {
		szTpmPasswd = getenv(szTpmPasswdInput);
		if(!szTpmPasswd) {
			logError(_("%s is not defined\n"), szTpmPasswdInput);
			goto out_close;
		}
	}
	else if( isTpmPasswdInputRequired ) {
		// Prompt for owner password
		szTpmPasswd = GETPASSWD(_("Enter owner password: "), &pswd_len, FALSE);
		if (!szTpmPasswd) {
			logMsg(_("Failed to get password\n"));
			goto out_close;
		}
	}
	else {
		tResult = tpmGetPubEk(hTpm, FALSE, NULL, &hEk);
		if (tResult == TCPA_E_DISABLED_CMD) {
			logInfo
				(_("Public PubEk access blocked, owner password required\n"));
			// Prompt for owner password
			szTpmPasswd = GETPASSWD(_("Enter owner password: "), &pswd_len, FALSE);
			if (szTpmPasswd) {
				logMsg(_("Failed to get password\n"));
				goto out_close;
			}
		}
	}
	if( szTpmPasswd ) {
		if (policyGet(hTpm, &hTpmPolicy) != TSS_SUCCESS)
			goto out_close;

		if( decodeHexPassword && !isWellKnown ) {
			if( hex2bytea(szTpmPasswd,&pTpmPasswdBytes,&iTpmPasswdBytesLen) != 0 ) {
				logError(_("Invalid hex TPM owner secret\n"));
				goto out_close;
			}
			if( Tspi_Policy_SetSecret(hTpmPolicy, TSS_SECRET_MODE_PLAIN, iTpmPasswdBytesLen,
						pTpmPasswdBytes) != TSS_SUCCESS)
				goto out_close;
		}
		else {
			if( pswd_len < 0 )
				pswd_len = strlen(szTpmPasswd);
			if (policySetSecret(hTpmPolicy, pswd_len, (BYTE *)szTpmPasswd) != TSS_SUCCESS)
				goto out_close;
		}
		tResult = tpmGetPubEk(hTpm, TRUE, NULL, &hEk);
		if (tResult != TSS_SUCCESS)
			goto out_close;
	}

	logMsg(_("Public Endorsement Key:\n"));
	if (displayKey(hEk) != TSS_SUCCESS)
		goto out_close;

	iRc = 0;
	logSuccess(argv[0]);

      out_close:
	contextClose(hContext);

      out:
	if (szTpmPasswd && !isWellKnown && !useEnvironment)
		shredPasswd(szTpmPasswd);
	if( pTpmPasswdBytes )
		shredByteArray(pTpmPasswdBytes, iTpmPasswdBytesLen);

	return iRc;
}
