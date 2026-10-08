@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM WaveLight Topolyzer - custom network drive mapping
REM Author: Victor Schnor <victorschnor@gmail.com>
REM
REM Edit only the configuration block below.
REM No SMB username or password should be stored in this file.
REM The required credential must already exist in the target
REM Windows user's Credential Manager.
REM ============================================================

REM ---- Configuration -----------------------------------------
set "TARGET_USER=LASIK"
set "DRIVE=H:"
set "SHARE=\\192.168.25.145\Topolyzer"
set "LOG=%TEMP%\WaveLight_MapH.log"
set "MAXTRY=6"
REM ------------------------------------------------------------

REM Run only in the intended Windows user context.
if /I not "%USERNAME%"=="%TARGET_USER%" exit /b 0

REM Start a fresh log for this session, overwriting any previous log.
>"%LOG%" echo ==================================================
>>"%LOG%" echo %DATE% %TIME%  Network mapping starting
>>"%LOG%" echo USERNAME=%USERNAME% COMPUTERNAME=%COMPUTERNAME%
>>"%LOG%" echo DRIVE=%DRIVE% SHARE=%SHARE%

REM Remove any previous mapping for the selected drive letter.
net use %DRIVE% /delete /y >>"%LOG%" 2>&1

REM Recreate the mapping using the credential already stored
REM in the current Windows user's profile.
set /a TRY=1

:MAPTRY
>>"%LOG%" echo Attempt !TRY! of %MAXTRY%
net use %DRIVE% "%SHARE%" /persistent:no >>"%LOG%" 2>&1

if !ERRORLEVEL! EQU 0 goto MAPPED

if !TRY! GEQ %MAXTRY% goto FAILED

set /a TRY+=1
timeout /t 1 /nobreak >nul 2>&1
goto MAPTRY

:MAPPED
>>"%LOG%" echo Mapping successful.
net use %DRIVE% >>"%LOG%" 2>&1
>>"%LOG%" echo %DATE% %TIME%  Network mapping finished successfully
>>"%LOG%" echo.
endlocal
exit /b 0

:FAILED
>>"%LOG%" echo Mapping failed after %MAXTRY% attempts.
>>"%LOG%" echo %DATE% %TIME%  Network mapping finished with failure
>>"%LOG%" echo.
endlocal
exit /b 0
