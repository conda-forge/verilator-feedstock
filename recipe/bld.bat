@echo on
setlocal EnableExtensions

if exist "%BUILD_PREFIX%\Library\mingw-w64\bin" set "PATH=%BUILD_PREFIX%\Library\mingw-w64\bin;%PATH%"
if exist "%BUILD_PREFIX%\Library\usr\bin" set "PATH=%BUILD_PREFIX%\Library\usr\bin;%PATH%"
set "CC=gcc"
set "CXX=g++"

set "BASH=%BUILD_PREFIX%\Library\usr\bin\bash.exe"
if not exist "%BASH%" (
    echo ERROR: bash not found at "%BASH%".
    echo Install m2-bash in build requirements for Windows.
    exit /b 1
)

"%BASH%" -lc "true"
if errorlevel 1 exit /b 1

"%BASH%" -lc "set -e; export PATH=\"$BUILD_PREFIX/Library/mingw-w64/bin:$BUILD_PREFIX/Library/mingw64/bin:$BUILD_PREFIX/Library/usr/bin:$PATH\"; cd \"$SRC_DIR\"; bash \"$RECIPE_DIR/build.sh\""
if errorlevel 1 exit /b 1
