@echo off

::------------------------------
::
:: Relase / Debug
::
::------------------------------
SET /A RELEASE_BUILD=0


::------------------------------
::
:: Environment Settings
:: App name, architecture
::
::------------------------------
@SET SCRIPT_DIR=%cd%
@SET SOURCE_DIR=%SCRIPT_DIR%\source
@SET APP_ARCH=x64


::------------------------------
::
:: Compile Engine
:: Requires Visual Studio 2019
::
::------------------------------
@SET VC_VARS_2019="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat"
@SET VC_VARS_2017="C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat"

@SET ERRORLEVEL=0
where cl >nul 2>nul
IF EXIST %VC_VARS_2019% (
    call %VC_VARS_2019% %APP_ARCH% >nul
    GOTO :COMPILE_AND_LINK
)
IF EXIST %VC_VARS_2017% (
    call %VC_VARS_2017% %APP_ARCH%
    GOTO :COMPILE_AND_LINK
)
GOTO :VS_NOT_FOUND

:COMPILE_AND_LINK
mkdir bin >nul 2>nul
:: Store msvc clutter elsewhere
mkdir msvc_landfill >nul 2>nul
pushd msvc_landfill >nul

:: Compile & Link Options
::------------------------------
:: /TC                  Compile as C code.
:: /TP                  Compile as C++ code.
:: /Oi                  Enable intrinsic functions.
:: /Od 	                Disables optimization.
:: /Qpar                Enable parallel code generation.
:: /Ot                  Favor fast code (over small code).
:: /Ob2                 Enable full inline expansion. [ cfarvin::NOTE ] Debugging impact.
:: /Z7	                Full symbolic debug info. No pdb. (See /Zi, /Zl).
:: /GS	                Detect buffer overruns.
:: /MD	                Multi-thread specific, DLL-specific runtime lib. (See /MDd, /MT, /MTd, /LD, /LDd).
:: /GL	                Whole program optimization.
:: /EHsc                No exception handling (Unwind semantics requrie vstudio env). (See /W1).
:: /I<arg>              Specify include directory.
:: /link                Invoke microsoft linker options.
:: /NXCOMPAT            Comply with Windows Data Execution Prevention.
:: /MACHINE:<arg>       Declare machine arch (should match vcvarsall env setting).
:: /NODEFAULTLIB:<arg>  Ignore a library.
:: /LIBPATH:<arg>       Specify library directory/directories.

:: General Parameters
SET GeneralParameters=/Oi /Qpar /EHsc /GL /nologo /Ot

:: Debug Paramters
SET DebugParameters=/Od /MTd /W4 /WX /D__UE_debug__#1

:: Release Parameters
SET ReleaseParameters=/MT /O2 /W4 /WX /Ob2

:: Include Parameters
SET IncludeParameters=/I%cd%\..

:: Link Parameters
SET LinkParameters=/SUBSYSTEM:CONSOLE ^
/NXCOMPAT ^
/MACHINE:x64 ^
user32.lib


:: Compiler Invocation
::------------------------------
@SET APP_NAME=_Generic
cl %DebugParameters% %SOURCE_DIR%\\%APP_NAME%.c %GeneralParameters% %IncludeParameters% /link %LinkParameters%
IF EXIST %APP_NAME%.exe (xcopy /y %APP_NAME%.exe ..\bin >nul) ELSE (GOTO :exit)

popd >nul
echo Done.
echo.
GOTO :exit


:VS_NOT_FOUND
echo.
echo Unable to find vcvarsall.bat. Did you install Visual Studio to the default location?
echo This build script requries either Visual Studio 2019 or 2017; with the standard C/C++ toolset.
echo.

:exit
