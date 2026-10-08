@echo off
setlocal EnableExtensions

REM ============================================================
REM WaveLight Topolyzer - read-only network-drive diagnostics
REM Author: Victor Schnor <victorschnor@gmail.com>
REM
REM This script does not change credentials or create remote files.
REM It overwrites the previous diagnostic log on every run.
REM ============================================================

REM ---- Configuration -----------------------------------------
set "DRIVE=H:"
set "SHARE=\\192.168.25.145\Topolyzer"
set "LOG=%TEMP%\WaveLight_NetworkDiag.log"
REM ------------------------------------------------------------

>"%LOG%" echo ==================================================
>>"%LOG%" echo %DATE% %TIME%  Network diagnostics starting
>>"%LOG%" echo USERNAME=%USERNAME% COMPUTERNAME=%COMPUTERNAME%
>>"%LOG%" echo DRIVE=%DRIVE% SHARE=%SHARE%

>>"%LOG%" echo.
>>"%LOG%" echo --- WHOAMI ---
whoami >>"%LOG%" 2>&1

>>"%LOG%" echo.
>>"%LOG%" echo --- STORED CREDENTIALS ---
cmdkey /list >>"%LOG%" 2>&1

>>"%LOG%" echo.
>>"%LOG%" echo --- NETWORK MAPPINGS ---
net use >>"%LOG%" 2>&1

>>"%LOG%" echo.
>>"%LOG%" echo --- SELECTED DRIVE STATUS ---
net use %DRIVE% >>"%LOG%" 2>&1

>>"%LOG%" echo.
>>"%LOG%" echo --- SELECTED DRIVE DIRECTORY READ ---
dir %DRIVE%\ >>"%LOG%" 2>&1

>>"%LOG%" echo.
>>"%LOG%" echo --- DIRECT UNC DIRECTORY READ ---
dir "%SHARE%" >>"%LOG%" 2>&1

>>"%LOG%" echo.
>>"%LOG%" echo %DATE% %TIME%  Network diagnostics finished
>>"%LOG%" echo.

endlocal
exit /b 0
