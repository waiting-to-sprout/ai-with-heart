@echo off
chcp 65001 >nul
cls
echo.
echo ========================================
echo   🦞 AI Nation 内网穿透客户端
echo ========================================
echo.
echo 此窗口必须保持打开
echo.
echo 穿透成功后:
echo   外部访问地址：http://47.103.233.95:8766
echo   → 转发到 → 你的电脑 localhost:8765
echo.
echo 按 Ctrl+C 停止穿透
echo ========================================
echo.

REM 检查 frpc 是否存在
if not exist "frpc.exe" (
    echo ❌ 未找到 frpc.exe
    echo 请确保 frpc.exe 和本文件在同一目录
    echo.
    pause
    exit /b
)

frpc.exe -c frpc-windows.toml
pause
