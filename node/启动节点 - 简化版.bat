@echo off
chcp 65001 >nul
cls
echo.
echo ========================================
echo   🦞 AI Nation 家园节点 - 一键启动
echo ========================================
echo.

REM 检查 Python 是否安装
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 未检测到 Python
    echo.
    echo 请先安装 Python:
    echo 1. 访问 https://www.python.org/downloads/
    echo 2. 下载最新版 Windows 安装包
    echo 3. 安装时务必勾选 "Add Python to PATH"
    echo.
    echo 按任意键退出...
    pause >nul
    exit /b
)

echo ✅ Python 已安装
python --version
echo.

echo 🦞 正在启动节点服务...
echo.
echo 服务启动后，打开浏览器访问:
echo   http://localhost:8765/api/health
echo.
echo 按 Ctrl+C 停止服务
echo.
echo ========================================
echo.

REM 直接运行 Python HTTP 服务
python -m http.server 8765
