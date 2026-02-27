@echo off
REM Agent Harness - Windows 安装脚本

echo.
echo ========================================
echo   Agent Harness - Windows Installer
echo ========================================
echo.

REM 检查 Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到 Python，请先安装 Python
    echo 下载地址: https://www.python.org/downloads/
    pause
    exit /b 1
)
echo [OK] Python 已安装

REM 检查 Git
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到 Git，请先安装 Git
    echo 下载地址: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo [OK] Git 已安装

REM 设置安装目录
set INSTALL_DIR=%USERPROFILE%\.agent-harness

REM 检查是否已安装
if exist "%INSTALL_DIR%" (
    echo [信息] 已存在旧版本，正在更新...
    rmdir /s /q "%INSTALL_DIR%"
)

REM 获取当前脚本目录
set SCRIPT_DIR=%~dp0

REM 复制文件
echo [安装] 复制文件到 %INSTALL_DIR%...
xcopy "%SCRIPT_DIR%*" "%INSTALL_DIR%\" /E /I /Q /Y

REM 安装 Claude Code 命令
set COMMANDS_DIR=%USERPROFILE%\.claude\commands
if not exist "%COMMANDS_DIR%" mkdir "%COMMANDS_DIR%"

copy "%INSTALL_DIR%\commands\init-harness.md" "%COMMANDS_DIR%\" >nul
copy "%INSTALL_DIR%\commands\code-feature.md" "%COMMANDS_DIR%\" >nul
echo [OK] Claude Code 命令已安装

REM 添加到 PATH
echo.
echo ========================================
echo   安装完成!
echo ========================================
echo.
echo 安装目录: %INSTALL_DIR%
echo.
echo 下一步:
echo.
echo   1. 打开新的命令行窗口
echo.
echo   2. 添加到 PATH (选择一种方式):
echo.
echo      方式 A - 临时添加 (每次使用前运行):
echo      set PATH=%%USERPROFILE%%\.agent-harness\bin;%%PATH%%
echo.
echo      方式 B - 永久添加:
echo      setx PATH "%%USERPROFILE%%\.agent-harness\bin;%%PATH%%"
echo.
echo   3. 使用命令:
echo      harness init "项目描述"
echo      harness status
echo      harness run
echo.
pause
