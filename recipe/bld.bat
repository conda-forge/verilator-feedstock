@echo on
setlocal EnableExtensions

set "BASH=%BUILD_PREFIX%\Library\usr\bin\bash.exe"
if not exist "%BASH%" (
    echo ERROR: bash not found at "%BASH%".
    echo Install m2-bash in build requirements for Windows.
    exit /b 1
)

"%BASH%" -lc "set -e; cd \"$SRC_DIR\"; bash \"$RECIPE_DIR/build.sh\""
if errorlevel 1 exit /b 1
