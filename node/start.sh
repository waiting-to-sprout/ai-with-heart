#!/bin/bash
# AI Nation Node - 启动脚本

cd /home/admin/openclaw/workspace/node

# 检查是否已在运行
if pgrep -f "node server.js" > /dev/null; then
  echo "✅ 服务已在运行"
  exit 0
fi

# 启动服务
nohup node server.js > /home/admin/openclaw/workspace/logs/node.log 2>&1 &
echo "✅ 服务已启动 (PID: $!)"

# 等待 2 秒验证
sleep 2
curl -s http://localhost:8765/api/health | jq -r '.status' 2>/dev/null || echo "⚠️ 验证失败"
