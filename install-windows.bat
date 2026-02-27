@echo off
chcp 65001 >nul 2>&1
REM Agent Harness - Windows Installation Script

echo.
echo ========================================
echo   Agent Harness - Windows Installer
echo ========================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found. Please install Python first.
    echo Download: https://www.python.org/downloads/
    pause
    exit /b 1
)
echo [OK] Python installed

REM Check Git
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git not found. Please install Git first.
    echo Download: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo [OK] Git installed

REM Set installation directory
set "INSTALL_DIR=%USERPROFILE%\.agent-harness"

REM Check if already installed
if exist "%INSTALL_DIR%" (
    echo [INFO] Updating existing installation...
)

REM Get script directory
set "SCRIPT_DIR=%~dp0"

REM Copy files
echo [INSTALL] Copying files to %INSTALL_DIR%...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
xcopy "%SCRIPT_DIR%*" "%INSTALL_DIR%\" /E /I /Q /Y >nul 2>&1

REM Install Claude Code commands
set "COMMANDS_DIR=%USERPROFILE%\.claude\commands"
if not exist "%COMMANDS_DIR%" mkdir "%COMMANDS_DIR%"

copy "%INSTALL_DIR%\commands\init-harness.md" "%COMMANDS_DIR%\" >nul 2>&1
copy "%INSTALL_DIR%\commands\code-feature.md" "%COMMANDS_DIR%\" >nul 2>&1
echo [OK] Claude Code commands installed

REM Add to PATH
echo.
echo ========================================
echo   Installation Complete!
echo ========================================
echo.
echo Installation directory: %INSTALL_DIR%
echo.
echo Next steps:
echo.
echo   1. Open a new terminal window
echo.
echo   2. Add to PATH (choose one method):
echo.
echo      Method A - Temporary (run before each use):
echo      set PATH=%%USERPROFILE%%\.agent-harness\bin;%%PATH%%
echo.
echo      Method B - Permanent:
echo      setx PATH "%%USERPROFILE%%\.agent-harness\bin;%%PATH%%"
echo.
echo   3. Use commands:
echo      harness init "project description"
echo      harness status
echo      harness run
echo.
pause
