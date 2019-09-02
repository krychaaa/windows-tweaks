@echo off

echo Running %~n0...

cd /d "%~dp0"

if "%1"=="ok" goto SKIP_ELEVATE
echo call :Elevate "%0" ok
call :Elevate "%0" ok
exit
:SKIP_ELEVATE

goto ElevateEnd

:Elevate
	set COMMAND=%*
	ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs" 
	ECHO UAC.ShellExecute "cmd", "/c %COMMAND%", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs" 
	"%temp%\OEgetPrivileges.vbs"
goto :eof

:ElevateEnd

REM ================================================================

echo Cleaning System...

REM Import Disk Cleanup settings
reg import cleanmgr.reg >nul

echo Running Disk Cleanup...
REM Uncheck Defender, Temporal Files
cleanmgr /sagerun:1

REM REM remove driver backups (view: pnputil -e)
REM REM NOTE: not active drivers (like printer ones) will be removed too
REM for /l %%N in (1,1,30) do pnputil -d oem%%N.inf >nul

REM clear event logs, some logs cannot be cleared
echo Clearing event logs...
for /f %%E in ('wevtutil el') do wevtutil cl %%E 2>nul

echo Cleaning WinSxS folder...
DISM /Online /Cleanup-Image /StartComponentCleanup

echo Cleaning Startup folder...
del "%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\*.*" 2>nul

echo Fixing broken System files...

REM Such files may appear after previous command
DISM /Online /Cleanup-image /Restorehealth
sfc /scannow

