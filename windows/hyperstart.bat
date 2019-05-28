@ECHO off
:top
CLS
ECHO Choose a shell:
ECHO [1] cmd
ECHO [2] Linux shell
ECHO [3] PowerShell
ECHO [4] PowerShell Core
ECHO [5] Python
ECHO [6] Visual Studio Developer Command Prompt
ECHO.
ECHO [7] restart elevated
ECHO [8] exit
ECHO.

CHOICE /N /C:12345678 /M "> "
CLS
IF ERRORLEVEL ==8 GOTO end
IF ERRORLEVEL ==7 powershell -Command "Start-Process hyper -Verb RunAs"
IF ERRORLEVEL ==6 cmd /k "C:\Program Files (x86)\Microsoft Visual Studio\2019\Preview\VC\Auxiliary\Build\vcvars64.bat" 
IF ERRORLEVEL ==5 python 
IF ERRORLEVEL ==4 "C:\Program Files\PowerShell\6\pwsh.exe"
IF ERRORLEVEL ==3 powershell
IF ERRORLEVEL ==2 cmd --login -i /c wsl
IF ERRORLEVEL ==1 cmd

CLS
ECHO Switch or exit?
ECHO [1] Switch
ECHO [2] Exit

CHOICE /N /C:12 /D 2 /T 5 /M "> "
IF ERRORLEVEL ==2 GOTO end
IF ERRORLEVEL ==1 GOTO top

:end
