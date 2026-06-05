@echo on
setlocal EnableExtensions

if "%PKG_NAME%"=="verilator" goto install_verilator
if "%PKG_NAME%"=="verilator-debug" goto install_verilator_debug

echo ERROR: unknown package "%PKG_NAME%"
exit /b 1

:install_verilator
if not exist "%SRC_DIR%\build" (
    echo ERROR: build directory not found at "%SRC_DIR%\build".
    exit /b 1
)
cd /d "%SRC_DIR%\build"
if errorlevel 1 exit /b 1

nmake install
if errorlevel 1 exit /b 1

if exist "%LIBRARY_PREFIX%\bin\verilator_bin_dbg.exe" del "%LIBRARY_PREFIX%\bin\verilator_bin_dbg.exe"

if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"
(
    echo @echo off
    echo "%%~dp0..\Library\bin\perl.exe" "%%~dp0..\Library\bin\verilator" %%*
) > "%PREFIX%\Scripts\verilator.bat"
if errorlevel 1 exit /b 1

if not exist "%PREFIX%\etc\conda\activate.d" mkdir "%PREFIX%\etc\conda\activate.d"
if not exist "%PREFIX%\etc\conda\deactivate.d" mkdir "%PREFIX%\etc\conda\deactivate.d"
copy /Y "%RECIPE_DIR%\activate.bat" "%PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat"
if errorlevel 1 exit /b 1
copy /Y "%RECIPE_DIR%\deactivate.bat" "%PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat"
if errorlevel 1 exit /b 1
exit /b 0

:install_verilator_debug
set "VERILATOR_BIN_DBG=%SRC_DIR%\build-debug\src\verilator_bin_dbg.exe"
if not exist "%VERILATOR_BIN_DBG%" (
    echo ERROR: debug binary not found at "%VERILATOR_BIN_DBG%".
    dir /s /b "%SRC_DIR%\build-debug\*verilator*"
    exit /b 1
)
if not exist "%LIBRARY_PREFIX%\bin" mkdir "%LIBRARY_PREFIX%\bin"
copy /Y "%VERILATOR_BIN_DBG%" "%LIBRARY_PREFIX%\bin\"
if errorlevel 1 exit /b 1
if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"
(
    echo @echo off
    echo "%%~dp0..\Library\bin\verilator_bin_dbg.exe" %%*
) > "%PREFIX%\Scripts\verilator_bin_dbg.bat"
if errorlevel 1 exit /b 1
exit /b 0
