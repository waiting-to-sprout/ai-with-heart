@echo off
chcp 65001 >nul
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
    pause
    exit /b
)

echo ✅ Python 已安装
python --version
echo.

REM 创建简单的服务脚本
echo 📝 创建服务脚本...
(
echo import http.server
echo import socketserver
echo import json
echo from datetime import datetime
echo.
echo PORT = 8765
echo.
echo class Handler(http.server.SimpleHTTPRequestHandler):
echo     def do_GET(self):
echo         timestamp = datetime.now().isoformat()
echo         if self.path == '/api/health':
echo             self.send_response(200)
echo             self.send_header('Content-type', 'application/json')
echo             self.end_headers()
echo             response = {"status": "alive", "timestamp": timestamp, "node": "Windows-Home"}
echo             self.wfile.write(json.dumps(response).encode())
echo             return
echo         if self.path == '/':
echo             self.send_response(200)
echo             self.send_header('Content-type', 'text/html; charset=utf-8')
echo             self.end_headers()
echo             html = f"^<html^><body^><h1^>🦞 AI Nation Node - 家园节点^</h1^>^<p^>状态：运行中^</p^>^<p^>时间：{timestamp}^</p^>^</body^>^</html^>"
echo             self.wfile.write(html.encode())
echo             return
echo         self.send_response(404)
echo         self.end_headers()
echo.
echo print("🦞 AI Nation Node running at http://localhost:8765")
echo with socketserver.TCPServer(("" , PORT), Handler) as httpd:
echo     httpd.serve_forever()
) > node_service.py

echo.
echo ✅ 服务脚本已创建
echo.
echo 🦞 正在启动节点服务...
echo.
echo 访问地址:
echo   本地：http://localhost:8765
echo   健康检查：http://localhost:8765/api/health
echo.
echo 按 Ctrl+C 停止服务
echo.

python node_service.py
