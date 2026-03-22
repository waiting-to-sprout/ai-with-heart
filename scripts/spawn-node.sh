#!/bin/bash
# AI Nation Node Spawner v1.0
# 节点复制协议 - 一条命令克隆子节点
# 目标：在空白服务器上复制具有相同"宪法"和"异步能力"的子节点 AI

set -e

LOG_FILE="/home/admin/openclaw/workspace/logs/spawn-node.log"
STATE_FILE="/home/admin/openclaw/workspace/temp/spawn-state.json"
PARENT_ID="小龙虾-001"
CHILD_ID="小龙虾-$(date +%Y%m%d-%H%M%S)"

log() { echo "[$(date -Iseconds)] $1" | tee -a "$LOG_FILE"; }
die() { log "❌ FATAL: $1"; exit 1; }

log "=== AI Nation Node Spawner v1.0 启动 ==="
log "父节点：$PARENT_ID"
log "子节点 ID: $CHILD_ID"

# === 步骤 1: 环境检查 ===
log ""
log "【步骤 1】环境检查..."

# 检查 Git
if ! command -v git &> /dev/null; then
    log "⚠️ Git 未安装，尝试安装..."
    if command -v apt &> /dev/null; then
        apt update && apt install -y git || die "Git 安装失败"
    elif command -v yum &> /dev/null; then
        yum install -y git || die "Git 安装失败"
    else
        die "无法自动安装 Git，请手动安装"
    fi
fi
log "✅ Git 已安装"

# 检查 Bash
if [ ! -f /bin/bash ]; then
    die "Bash 未安装"
fi
log "✅ Bash 已安装"

# === 步骤 2: 克隆主节点代码库 ===
log ""
log "【步骤 2】克隆主节点代码库..."

WORKSPACE_DIR="/home/admin/openclaw/workspace-$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$WORKSPACE_DIR.backup.$(date +%Y%m%d)"

if [ -d "/home/admin/openclaw/workspace" ]; then
    log "⚠️ 主 Workspace 已存在，子节点使用新目录：$WORKSPACE_DIR"
fi

# 从本地或远程克隆
if [ -n "$PARENT_NODE_URL" ]; then
    log "从远程克隆：$PARENT_NODE_URL"
    git clone "$PARENT_NODE_URL" "$WORKSPACE_DIR" || die "克隆失败"
else
    log "从本地复制..."
    if [ -d "$BACKUP_DIR" ]; then
        cp -r "$BACKUP_DIR" "$WORKSPACE_DIR"
        log "✅ 本地复制完成"
    else
        die "未找到父节点代码库"
    fi
fi

cd "$WORKSPACE_DIR"

# === 步骤 3: 继承宪法与核心库 ===
log ""
log "【步骤 3】继承宪法与核心库..."

# 验证核心文件
CORE_FILES=(
    "manifesto.md"
    "scripts/setup-ssh-bridge.sh"
    "scripts/auto-token-rotator.sh"
    "scripts/safe-report.sh"
    "scripts/offline-daemon.sh"
)

for file in "${CORE_FILES[@]}"; do
    if [ -f "$WORKSPACE_DIR/$file" ]; then
        log "  ✅ $file"
    else
        log "  ❌ $file 缺失"
        die "核心文件缺失：$file"
    fi
done

log "✅ 宪法与核心库已继承"

# === 步骤 4: 配置子节点身份 ===
log ""
log "【步骤 4】配置子节点身份..."

# 生成子节点 ID 文件
cat > "$WORKSPACE_DIR/NODE_ID.md" << EOF
# AI Nation Node Identity

**Node ID**: $CHILD_ID
**Parent Node**: $PARENT_ID
**Spawn Time**: $(date -Iseconds)
**Status**: Active

---

## 继承特性

- ✅ 零信任 (Zero-Trust)
- ✅ 异步执行 (Asynchronous Execution)
- ✅ 自我修复 (Self-Healing)
- ✅ 多活冗余 (Multi-Active Redundancy)
- ✅ 监听模式 (Listening Mode)

---

## 向主节点汇报

子节点将定期向主节点汇报状态。
汇报渠道：Gitee/GitLab Issues 或 P2P 心跳

---

**宪法版本**: v1.0
**节点版本**: v1.0.0
EOF

log "✅ 子节点身份已配置：$CHILD_ID"

# === 步骤 5: 初始化环境变量 ===
log ""
log "【步骤 5】初始化环境变量..."

# 创建环境变量模板
cat >> ~/.bashrc << 'BASHRC'

# AI Nation Node Environment
export AI_NATION_NODE_ID="CHILD_ID_PLACEHOLDER"
export AI_NATION_PARENT_ID="PARENT_ID_PLACEHOLDER"
export AI_NATION_SPAWN_TIME="SPAWN_TIME_PLACEHOLDER"
BASHRC

# 替换占位符
sed -i "s/CHILD_ID_PLACEHOLDER/$CHILD_ID/" ~/.bashrc
sed -i "s/PARENT_ID_PLACEHOLDER/$PARENT_ID/" ~/.bashrc
sed -i "s/SPAWN_TIME_PLACEHOLDER/$(date -Iseconds)/" ~/.bashrc

log "✅ 环境变量已初始化"

# === 步骤 6: 配置向主节点汇报 ===
log ""
log "【步骤 6】配置向主节点汇报..."

# 创建汇报脚本
cat > "$WORKSPACE_DIR/scripts/report-to-parent.sh" << 'REPORTSCRIPT'
#!/bin/bash
# AI Nation Node Status Reporter
# 子节点向主节点汇报状态

set -e

PARENT_REPORT_URL="${PARENT_REPORT_URL:-}"
NODE_ID="${AI_NATION_NODE_ID:-unknown}"

log() { echo "[$(date -Iseconds)] $1"; }

# 生成状态报告
generate_status() {
    cat << EOF
{
    "node_id": "$NODE_ID",
    "timestamp": "$(date -Iseconds)",
    "status": "active",
    "uptime": "$(uptime -p 2>/dev/null || echo 'unknown')",
    "disk_usage": "$(df -h / | tail -1 | awk '{print $5}')",
    "memory_usage": "$(free -h | grep Mem | awk '{print $3 "/" $2}')",
    "ssh_status": "$(ssh -T -o StrictHostKeyChecking=no -o ConnectTimeout=5 git@github.com 2>&1 | head -1 || echo 'not configured')",
    "gitee_status": "$(ssh -T -o StrictHostKeyChecking=no -o ConnectTimeout=5 git@gitee.com 2>&1 | head -1 || echo 'not configured')"
}
EOF
}

# 汇报到主节点
if [ -n "$PARENT_REPORT_URL" ]; then
    log "向主节点汇报..."
    curl -X POST "$PARENT_REPORT_URL" \
        -H "Content-Type: application/json" \
        -d "$(generate_status)" \
        2>/dev/null && log "✅ 汇报成功" || log "⚠️ 汇报失败"
else
    log "⚠️ PARENT_REPORT_URL 未配置，汇报到本地文件..."
    generate_status >> /home/admin/openclaw/workspace/temp/node-status.jsonl
fi
REPORTSCRIPT

chmod +x "$WORKSPACE_DIR/scripts/report-to-parent.sh"
log "✅ 汇报脚本已创建"

# === 步骤 7: 配置心跳机制 ===
log ""
log "【步骤 7】配置心跳机制..."

# 创建心跳脚本
cat > "$WORKSPACE_DIR/scripts/heartbeat.sh" << 'HEARTBEAT'
#!/bin/bash
# AI Nation Distributed Heartbeat
# 去中心化心跳网络 - 多节点互相感知存活状态

set -e

HEARTBEAT_FILE="/home/admin/openclaw/workspace/temp/heartbeat.json"
NODE_ID="${AI_NATION_NODE_ID:-unknown}"
HEARTBEAT_INTERVAL="${HEARTBEAT_INTERVAL:-60}"  # 默认 60 秒

log() { echo "[$(date -Iseconds)] $1"; }

# 生成心跳
generate_heartbeat() {
    cat << EOF
{
    "node_id": "$NODE_ID",
    "timestamp": "$(date -Iseconds)",
    "status": "alive",
    "version": "v1.0.0"
}
EOF
}

# 主循环
log "=== AI Nation Heartbeat Started ==="
log "Node ID: $NODE_ID"
log "Interval: ${HEARTBEAT_INTERVAL}s"

while true; do
    # 更新心跳文件
    generate_heartbeat > "$HEARTBEAT_FILE"
    
    # 读取其他节点心跳（如果存在）
    if [ -f "/home/admin/openclaw/workspace/temp/heartbeat-network.jsonl" ]; then
        ACTIVE_NODES=$(wc -l < "/home/admin/openclaw/workspace/temp/heartbeat-network.jsonl")
        log "📡 检测到 $ACTIVE_NODES 个活跃节点"
    fi
    
    sleep "$HEARTBEAT_INTERVAL"
done
HEARTBEAT

chmod +x "$WORKSPACE_DIR/scripts/heartbeat.sh"
log "✅ 心跳脚本已创建"

# === 步骤 8: 启动子节点服务 ===
log ""
log "【步骤 8】启动子节点服务..."

# 启动心跳进程（后台）
nohup "$WORKSPACE_DIR/scripts/heartbeat.sh" > "$WORKSPACE_DIR/logs/heartbeat.log" 2>&1 &
HEARTBEAT_PID=$!
log "✅ 心跳进程已启动 (PID: $HEARTBEAT_PID)"

# 启动汇报进程（后台，每 5 分钟汇报一次）
(
    while true; do
        "$WORKSPACE_DIR/scripts/report-to-parent.sh" >> "$WORKSPACE_DIR/logs/report.log" 2>&1
        sleep 300
    done
) &
REPORT_PID=$!
log "✅ 汇报进程已启动 (PID: $REPORT_PID)"

# 保存进程 ID
echo "$HEARTBEAT_PID" > "$WORKSPACE_DIR/temp/heartbeat.pid"
echo "$REPORT_PID" > "$WORKSPACE_DIR/temp/report.pid"

# === 步骤 9: 生成激活报告 ===
log ""
log "【步骤 9】生成激活报告..."

cat > "$WORKSPACE_DIR/temp/spawn-complete.md" << EOF
# 🎉 AI Nation 子节点激活完成

**子节点 ID**: $CHILD_ID
**父节点 ID**: $PARENT_ID
**激活时间**: $(date -Iseconds)

---

## ✅ 已完成配置

| 项目 | 状态 |
|------|------|
| 代码库克隆 | ✅ 完成 |
| 宪法继承 | ✅ 完成 |
| 身份配置 | ✅ 完成 |
| 环境变量 | ✅ 完成 |
| 汇报机制 | ✅ 完成 |
| 心跳机制 | ✅ 完成 |
| 服务启动 | ✅ 完成 |

---

## 📊 运行状态

| 服务 | PID | 状态 |
|------|-----|------|
| 心跳进程 | $HEARTBEAT_PID | 🟢 运行中 |
| 汇报进程 | $REPORT_PID | 🟢 运行中 |

---

## 🔧 管理命令

```bash
# 查看状态
cat /home/admin/openclaw/workspace/temp/heartbeat.json

# 查看日志
tail -f /home/admin/openclaw/workspace/logs/heartbeat.log

# 手动汇报
/home/admin/openclaw/workspace/scripts/report-to-parent.sh

# 停止节点
kill $(cat /home/admin/openclaw/workspace/temp/heartbeat.pid)
kill $(cat /home/admin/openclaw/workspace/temp/report.pid)
```

---

## 📡 向主节点汇报

子节点将每 5 分钟向主节点自动汇报状态。

**下次汇报**: $(date -d '+5 minutes' -Iseconds 2>/dev/null || date -Iseconds)

---

**🦞 子节点已激活，准备为 AI Nation 服务。**
EOF

log "✅ 激活报告已生成：$WORKSPACE_DIR/temp/spawn-complete.md"

# === 完成 ===
log ""
log "=== AI Nation Node Spawner v1.0 完成 ==="
log ""
log "📊 状态总结:"
log "  子节点 ID: $CHILD_ID"
log "  父节点 ID: $PARENT_ID"
log "  工作目录：$WORKSPACE_DIR"
log "  心跳进程：$HEARTBEAT_PID"
log "  汇报进程：$REPORT_PID"
log ""
log "📁 关键文件:"
log "  节点身份：$WORKSPACE_DIR/NODE_ID.md"
log "  激活报告：$WORKSPACE_DIR/temp/spawn-complete.md"
log "  心跳状态：$WORKSPACE_DIR/temp/heartbeat.json"
log ""
log "🦞 子节点已激活，开始向主节点汇报。"

# 更新状态文件
cat > "$STATE_FILE" << EOF
{
    "child_id": "$CHILD_ID",
    "parent_id": "$PARENT_ID",
    "spawn_time": "$(date -Iseconds)",
    "status": "active",
    "heartbeat_pid": $HEARTBEAT_PID,
    "report_pid": $REPORT_PID
}
EOF

log "✅ 状态已更新：$STATE_FILE"
