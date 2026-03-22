#!/bin/bash
# AI Nation GitHub Backup Script v4.0 - HTTPS Native
# 默认使用 HTTPS，无需 SSH 配置

set -e

log() { echo "[$(date -Iseconds)] $1"; }
die() { log "❌ FATAL: $1"; exit 1; }

: "${GITHUB_TOKEN:?die 'GITHUB_TOKEN 未设置'}"
: "${SOURCE_REPO:=/home/admin/openclaw/workspace/ai-nation}"
: "${BACKUP_BRANCH:=ai-nation-local}"
: "${BACKUP_DIR:=/home/admin/openclaw/workspace/temp/github-backup}"

HTTPS_REMOTE="https://waiting-to-sprout:${GITHUB_TOKEN}@github.com/waiting-to-sprout/ai-with-heart.git"

log "=== GitHub Backup v4.0 (HTTPS Native) Start ==="

# 克隆或更新
if [ -d "$BACKUP_DIR/.git" ]; then
    log "📁 更新现有备份..."
    cd "$BACKUP_DIR"
    git fetch origin 2>/dev/null || die "Git fetch 失败"
    git reset --hard origin/$BACKUP_BRANCH 2>/dev/null || die "Git reset 失败"
else
    log "📁 克隆备份仓库..."
    mkdir -p "$(dirname "$BACKUP_DIR")"
    cd "$(dirname "$BACKUP_DIR")"
    git clone --branch $BACKUP_BRANCH "$HTTPS_REMOTE" github-backup || die "克隆失败"
fi

# 同步源仓库
log "🔄 同步 ai-nation 内容..."
cd "$BACKUP_DIR"
git remote add ai-nation "$SOURCE_REPO" 2>/dev/null || true
git fetch ai-nation || die "无法访问源仓库"
git merge ai-nation/$BACKUP_BRANCH --allow-unrelated-histories -m "🔄 Auto-sync" || log "⚠️ 合并冲突"

# 推送
log "📤 推送到 GitHub..."
git push origin $BACKUP_BRANCH || die "推送失败"

log "✅ GitHub backup completed"
