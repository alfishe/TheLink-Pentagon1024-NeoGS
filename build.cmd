@echo off
rem The Link - build from source with the vendored sjasmplus (Windows).
rem
rem   build.cmd             the demo: build\TheLink-NonDirectorsCut.scl
rem   build.cmd experiment  the same from changed sources: differences from the author's files are reported
rem   build.cmd stage1      an earlier stage (materials\02-addons\README.md): stage1, stage2
rem   build.cmd clean       remove build\
rem
rem SJASMPLUS=C:\path\to\sjasmplus.exe uses another sjasmplus (1.23 or later, built with Lua).
rem Everything is built in build\obj (listings *.lst there too); a sjasmplus error or warning stops the build.
rem VERBOSE=1 also shows what the sources DISPLAY while they assemble (sizes and addresses the author printed).
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
rem sjasmplus warns about backslashes in file names: give it forward slashes
set "ROOTF=%ROOT:\=/%"
if defined SJASMPLUS (set "SJ=%SJASMPLUS%") else (set "SJ=%ROOT%\tools\sjasmplus\windows-x64\sjasmplus.exe")
if not exist "%SJ%" (
    echo no sjasmplus at %SJ%: set SJASMPLUS=C:\path\to\sjasmplus.exe
    exit /b 1
)

set "TARGET=%~1"
if "%TARGET%"=="" set "TARGET=demo"
set "OUT=%ROOT%\build"
set "BUILD=%OUT%\obj"
if /i "%TARGET%"=="clean" (
    if exist "%OUT%" rmdir /s /q "%OUT%"
    exit /b 0
)

if exist "%OUT%" rmdir /s /q "%OUT%"
mkdir "%BUILD%"
pushd "%BUILD%"
set "INC=-I%ROOTF%/src -I%ROOTF%/src/data -I."
for /f "delims=" %%v in ('"%SJ%" --version 2^>^&1') do (
    echo The Link: %TARGET%, %%v
    goto :versionDone
)
:versionDone

if /i "%TARGET%"=="experiment" set "ASMOPT_RELEASE=-DEXPERIMENT=1" & set "TARGET_DEMO=1"
if /i "%TARGET%"=="demo" set "TARGET_DEMO=1"
if defined TARGET_DEMO (
    set "RESULT=TheLink-NonDirectorsCut.scl"
    call :asm tools/tables.asm
    if errorlevel 1 goto :failed
    for %%u in (GSTUNNE4 GSROTAT7 GSRBAR24 GSMULBA3 hedge12 baba4 TEX28 THELINK) do (
        call :asm src/%%u.asm %INC%
        if errorlevel 1 goto :failed
    )
    call :asm src/loader/loader.asm
    if errorlevel 1 goto :failed
    set "ASMOPT=%ASMOPT_RELEASE%"
    call :asm tools/release.asm
    if errorlevel 1 goto :failed
    goto :done
)
if /i "%TARGET%"=="stage1" set "STAGEDIR=materials/02-addons/stage1-loader" & set "STAGE=1"
if /i "%TARGET%"=="stage2" set "STAGEDIR=materials/02-addons/stage2-machine-check" & set "STAGE=2"
if not defined STAGE (
    echo unknown target %TARGET% ^(demo, experiment, stage1, stage2, clean^)
    popd
    exit /b 2
)
set "RESULT=TheLink-stage%STAGE%.scl"
call :asm %STAGEDIR%/thelink_main.asm %INC%
if errorlevel 1 goto :failed
call :asm %STAGEDIR%/loader.asm
if errorlevel 1 goto :failed
rem An option with "=" cannot go through call's arguments (cmd splits at "="): :asm adds ASMOPT
set "ASMOPT=-DSTAGE=%STAGE%"
call :asm tools/release.asm
if errorlevel 1 goto :failed
set "ASMOPT="

:done
popd
echo done: %RESULT% in build\, boot it on a Pentagon 1024 with a NeoGS
exit /b 0

:failed
popd
exit /b 1

rem One assembly: %1 = the source (relative to the project), then sjasmplus' options. Its messages are shown; a
rem warning fails like an error.
:asm
set "SOURCE=%~1"
set "NAME=%~n1"
shift
set "OPTIONS="
:asmOptions
if "%~1"=="" goto :asmRun
set "OPTIONS=!OPTIONS! %1"
shift
goto :asmOptions
:asmRun
set "LOG=%BUILD%\%NAME%.log"
"%SJ%" --nologo --msg=war --lst=%NAME%.lst !OPTIONS! !ASMOPT! "%ROOTF%/%SOURCE%" > "%LOG%" 2>&1
if errorlevel 1 (
    echo   %SOURCE%   failed
    type "%LOG%"
    exit /b 1
)
echo   %SOURCE%   ok
rem tools/release.asm fails on any warning in these logs; it reports the results, the sources' DISPLAY lines
rem only with VERBOSE=1
if /i "%NAME%"=="release" (type "%LOG%") else if defined VERBOSE type "%LOG%"
exit /b 0
