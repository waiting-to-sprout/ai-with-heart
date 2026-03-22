#!/bin/bash
# AI Nation Gitee Backup Script v3.0 - SSH Native
# 默认使用 SSH，HTTPS 降级

set -e

log() { echo "[$(date -Iseconds)] $1"; }
die() { log "❌ FATAL: $1"; exit 1; }

: "${SOURCE_REPO:=/home/admin/openclaw/workspace/ai-nation}"
: "${BACKUP_DIR:=/home/admin/openclaw/workspace/temp/gitee-backup}"

SSH_REMOTE="git@gitee-ai-nation:wooden-connection/ai-nation-backup.git"
HTTPS_REMOTE="https://wooden-connection:${GITEE_TOKEN:-}@gitee.com/wooden-connection/ai-nation-backup.git"

log "=== Gitee Backup v3.0 (SSH Native) Start ==="

# 克隆或更新
if [ -d "$BACKUP_DIR/.git" ]; then
    log "📁 更新现有备份..."
    cd "$BACKUP_DIR"
    git fetch origin 2>/dev/null || die "Git fetch 失败"
    git reset --hard origin/master 2>/dev/null || die "Git reset 失败"
else
    log "📁 克隆备份仓库..."
    mkdir -p "$(dirname "$BACKUP_DIR")"
    cd "$(dirname "$BACKUP_DIR")"
    
    # 优先尝试 SSH
    if git clone "$SSH_REMOTE" gitee-backup 2>/dev/null; then
        log "✅ SSH 克隆成功"
    else
        log "⚠️ SSH 失败，降级到 HTTPS..."
        git clone "$HTTPS_REMOTE" gitee-backup || die "HTTPS 克隆失败"
    fi
fi

# 同步源仓库
log "🔄 同步 ai-nation 内容..."
cd "$BACKUP_DIR"
git remote add ai-nation "$SOURCE_REPO" 2>/dev/null || true
git fetch ai-nation || die "无法访问源仓库"
git merge ai-nation/ai-nation-local --allow-unrelated-histories -m "🔄 Auto-sync" || log "⚠️ 合并冲突"

# 推送
log "📤 推送到 Gitee..."
if git push origin master 2>/dev/null; then
    log "✅ SSH 推送成功"
else
    log "⚠️ SSH 推送失败，降级到 HTTPS..."
    git push origin master || die "HTTPS 推送失败"
fi

log "✅ Gitee backup completed"
