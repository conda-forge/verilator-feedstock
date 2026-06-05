@echo on
setlocal EnableExtensions

mkdir build
if errorlevel 1 exit /b 1
cd build
if errorlevel 1 exit /b 1

:: Verilator's CMake expects WIN_FLEX_BISON to point to the winflexbison prefix
set "WIN_FLEX_BISON=%BUILD_PREFIX%\Library"
set "FLEX_INCLUDE_DIR=%WIN_FLEX_BISON%\share\winflexbison"
set "FLEX_INCLUDE_DIR_CMAKE=%FLEX_INCLUDE_DIR:\=/%"
if not exist "%WIN_FLEX_BISON%" (
    echo ERROR: WIN_FLEX_BISON directory not found at "%WIN_FLEX_BISON%".
    echo winflexbison must be installed as a build dependency.
    exit /b 1
)
if not exist "%WIN_FLEX_BISON%\bin\win_flex.exe" (
    echo ERROR: win_flex.exe not found under "%WIN_FLEX_BISON%\bin".
    exit /b 1
)
if not exist "%WIN_FLEX_BISON%\bin\win_bison.exe" (
    echo ERROR: win_bison.exe not found under "%WIN_FLEX_BISON%\bin".
    exit /b 1
)
if not exist "%FLEX_INCLUDE_DIR%\FlexLexer.h" (
    echo ERROR: FlexLexer.h not found under "%FLEX_INCLUDE_DIR%".
    exit /b 1
)
copy /Y "%FLEX_INCLUDE_DIR%\FlexLexer.h" "%SRC_DIR%\src\FlexLexer.h"
if errorlevel 1 exit /b 1

cmake -G "NMake Makefiles" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DFLEX_INCLUDE_DIR="%FLEX_INCLUDE_DIR_CMAKE%" ^
    -DFLEX_INCLUDE_DIRS="%FLEX_INCLUDE_DIR_CMAKE%" ^
    "%SRC_DIR%"
if errorlevel 1 exit /b 1

nmake
if errorlevel 1 exit /b 1

cd ..
if errorlevel 1 exit /b 1
mkdir build-debug
if errorlevel 1 exit /b 1
cd build-debug
if errorlevel 1 exit /b 1

cmake -G "NMake Makefiles" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE=Debug ^
    -DFLEX_INCLUDE_DIR="%FLEX_INCLUDE_DIR_CMAKE%" ^
    -DFLEX_INCLUDE_DIRS="%FLEX_INCLUDE_DIR_CMAKE%" ^
    "%SRC_DIR%"
if errorlevel 1 exit /b 1

nmake
if errorlevel 1 exit /b 1
