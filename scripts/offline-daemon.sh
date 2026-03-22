#!/bin/bash
# AI Nation Offline Daemon v1.0
# 压力测试：无网缓存 + 自动重连推送
# 模拟"网络完全中断"场景的本地守护进程

set -e

log() { echo "[$(date -Iseconds)] $1"; }
die() { log "❌ FATAL: $1"; exit 1; }

# === 配置 ===
: "${SOURCE_REPO:=/home/admin/openclaw/workspace/ai-nation}"
: "${CACHE_DIR:=/home/admin/openclaw/workspace/temp/offline-cache}"
: "${STATE_FILE:=/home/admin/openclaw/workspace/temp/daemon-state.json}"
: "${CHECK_INTERVAL:=60}"  # 秒

mkdir -p "$CACHE_DIR"

# === 网络检测（多节点 ping）===
check_network() {
    ping -c1 -W2 20.205.243.166 >/dev/null 2>&1 && return 0  # github.com
    ping -c1 -W2 20.205.243.168 >/dev/null 2>&1 && return 0  # api.github.com
    curl -s --connect-timeout 2 https://gitee.com >/dev/null 2>&1 && return 0
    return 1
}

# === 缓存待提交数据 ===
cache_pending() {
    log "📦 检测到网络中断，启动离线缓存..."
    cd "$SOURCE_REPO"
    
    # 保存当前状态
    local pending_commits=$(git log --oneline @{u}..HEAD 2>/dev/null | wc -l)
    local pending_changes=$(git status --porcelain 2>/dev/null | wc -l)
    
    if [ "$pending_commits" -gt 0 ] || [ "$pending_changes" -gt 0 ]; then
        log "📝 发现 $pending_commits 个未推送提交，$pending_changes 个未提交变更"
        
        # 创建缓存快照
        local snapshot_file="$CACHE_DIR/snapshot-$(date +%Y%m%d-%H%M%S).tar.gz"
        tar -czf "$snapshot_file" -C "$(dirname "$SOURCE_REPO")" "$(basename "$SOURCE_REPO")" 2>/dev/null
        log "✅ 快照已保存：$snapshot_file"
        
        # 记录状态
        echo "{\"status\":\"offline\",\"pending_commits\":$pending_commits,\"snapshot\":\"$snapshot_file\",\"timestamp\":\"$(date -Iseconds)\"}" > "$STATE_FILE"
    else
        log "ℹ️ 无待缓存数据"
        echo "{\"status\":\"offline\",\"pending_commits\":0,\"timestamp\":\"$(date -Iseconds)\"}" > "$STATE_FILE"
    fi
}

# === 网络恢复后自动重连 ===
auto_reconnect() {
    log "🌐 检测到网络恢复，启动自动重连..."
    
    cd "$SOURCE_REPO"
    
    # 恢复缓存快照（如果有）
    local latest_snapshot=$(ls -t "$CACHE_DIR"/snapshot-*.tar.gz 2>/dev/null | head -1)
    if [ -n "$latest_snapshot" ]; then
        log "📦 发现缓存快照：$latest_snapshot"
        # 快照仅用于恢复，不自动应用（避免冲突）
    fi
    
    # 尝试推送
    log "📤 尝试推送到远程..."
    if git push origin ai-nation-local 2>&1 | grep -q "Authentication failed\|could not resolve host"; then
        log "❌ 推送失败 - 凭证或网络问题"
        echo "{\"status\":\"reconnect_failed\",\"reason\":\"auth_or_network\",\"timestamp\":\"$(date -Iseconds)\"}" > "$STATE_FILE"
        return 1
    fi
    
    log "✅ 推送成功！离线模式结束"
    echo "{\"status\":\"online\",\"last_sync\":\"$(date -Iseconds)\"}" > "$STATE_FILE"
    
    # 清理旧快照（保留最近 3 个）
    ls -t "$CACHE_DIR"/snapshot-*.tar.gz 2>/dev/null | tail -n +4 | xargs rm -f 2>/dev/null
    return 0
}

# === 主循环 ===
log "=== Offline Daemon v1.0 Started ==="
log "监控间隔：${CHECK_INTERVAL}秒"
log "源仓库：$SOURCE_REPO"
log "缓存目录：$CACHE_DIR"

last_status="unknown"

while true; do
    if check_network; then
        if [ "$last_status" != "online" ]; then
            log "🌐 网络状态：ONLINE"
            auto_reconnect && last_status="online" || last_status="reconnect_failed"
        fi
    else
        if [ "$last_status" != "offline" ]; then
            log "📴 网络状态：OFFLINE"
            cache_pending
            last_status="offline"
        fi
    fi
    
    sleep "$CHECK_INTERVAL"
done
