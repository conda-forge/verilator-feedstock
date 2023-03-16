echo on
setlocal EnableDelayedExpansion

mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

REM see https://github.com/verilator/verilator/blob/master/docs/guide/install-cmake.rst
set WIN_FLEX_BISON=%LIBRARY_PREFIX%\share\winflexbison

dir %WIN_FLEX_BISON%
dir %LIBRARY_BIN%

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH:PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    %SRC_DIR%
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1


:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    :: Copy unix shell activation scripts, needed by Windows Bash users
    :: copy %RECIPE_DIR%\%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
)
