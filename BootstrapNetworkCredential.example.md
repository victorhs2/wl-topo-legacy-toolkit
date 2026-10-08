@echo off
setlocal EnableExtensions

REM ============================================================
REM ONE-TIME EXAMPLE ONLY
REM
REM Purpose:
REM   Store an SMB credential in the Windows Credential Manager
REM   of the user context in which this script is executed.
REM
REM Security:
REM   1. Copy this file to BootstrapNetworkCredential.local.cmd
REM   2. Edit the LOCAL copy only.
REM   3. Never commit the local copy.
REM   4. Run it once in the LASIK startup context.
REM   5. Remove the startup call immediately after validation.
REM   6. Delete the temporary script from the Topolyzer.
REM ============================================================

REM ---- Replace these placeholders in the temporary local copy -
set "SERVER=__SERVER_IP_OR_HOSTNAME__"
set "SMBUSER=__DOMAIN_OR_WORKGROUP__\__USERNAME__"
set "SMBPASS=__TEMPORARY_PASSWORD_PLACEHOLDER__"
REM ------------------------------------------------------------

if /I not "%USERNAME%"=="LASIK" exit /b 0

REM Refuse to run if the example password placeholder is unchanged.
if "%SMBPASS%"=="__TEMPORARY_PASSWORD_PLACEHOLDER__" exit /b 2

REM Replace any existing credential for this server in the LASIK profile.
cmdkey /delete:%SERVER% >nul 2>&1
cmdkey /add:%SERVER% /user:%SMBUSER% /pass:%SMBPASS%

endlocal
exit /b %ERRORLEVEL%
