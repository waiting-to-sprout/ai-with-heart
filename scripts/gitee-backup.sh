#!/bin/bash
# AI Nation Gitee Backup Script v4.0 - HTTPS Native
# 默认使用 HTTPS，无需 SSH 配置

set -e

log() { echo "[$(date -Iseconds)] $1"; }
die() { log "❌ FATAL: $1"; exit 1; }

: "${GITEE_TOKEN:?die 'GITEE_TOKEN 未设置'}"
: "${GITEE_USERNAME:=wooden-connection}"
: "${SOURCE_REPO:=/home/admin/openclaw/workspace/ai-nation}"
: "${BACKUP_DIR:=/home/admin/openclaw/workspace/temp/gitee-backup}"

HTTPS_REMOTE="https://${GITEE_USERNAME}:${GITEE_TOKEN}@gitee.com/${GITEE_USERNAME}/ai-nation-backup.git"

log "=== Gitee Backup v4.0 (HTTPS Native) Start ==="

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
    git clone "$HTTPS_REMOTE" gitee-backup || die "克隆失败"
fi

# 同步源仓库
log "🔄 同步 ai-nation 内容..."
cd "$BACKUP_DIR"
git remote add ai-nation "$SOURCE_REPO" 2>/dev/null || true
git fetch ai-nation || die "无法访问源仓库"
git merge ai-nation/ai-nation-local --allow-unrelated-histories -m "🔄 Auto-sync" || log "⚠️ 合并冲突"

# 推送
log "📤 推送到 Gitee..."
git push origin master || die "推送失败"

log "✅ Gitee backup completed"
