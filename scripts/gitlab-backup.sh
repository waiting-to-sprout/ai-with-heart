#!/bin/bash
# AI Nation GitLab Backup Script v1.0
# 环境变量驱动，零本地凭证依赖

set -e

log() { echo "[$(date -Iseconds)] $1"; }
die() { log "❌ FATAL: $1"; exit 1; }

# 环境变量校验
: "${GITLAB_TOKEN:?die 'GITLAB_TOKEN 未设置'}"
: "${GITLAB_USERNAME:?die 'GITLAB_USERNAME 未设置'}"
: "${GITLAB_REPO:=ai-nation-backup}"
: "${SOURCE_REPO:=/home/admin/openclaw/workspace/ai-nation}"
: "${BACKUP_DIR:=/home/admin/openclaw/workspace/temp/gitlab-backup}"

GITLAB_URL="https://oauth2:${GITLAB_TOKEN}@gitlab.com/${GITLAB_USERNAME}/${GITLAB_REPO}.git"

log "=== GitLab Backup Start ==="

# 克隆或更新
if [ -d "$BACKUP_DIR/.git" ]; then
    log "📁 更新现有备份..."
    cd "$BACKUP_DIR"
    git fetch origin || die "Git fetch 失败"
    git reset --hard origin/master || die "Git reset 失败"
else
    log "📁 克隆备份仓库..."
    mkdir -p "$(dirname "$BACKUP_DIR")"
    cd "$(dirname "$BACKUP_DIR")"
    git clone "$GITLAB_URL" gitlab-backup || die "克隆失败"
fi

# 同步源仓库
log "🔄 同步 ai-nation 内容..."
cd "$BACKUP_DIR"
git remote add ai-nation "$SOURCE_REPO" 2>/dev/null || true
git fetch ai-nation || die "无法访问源仓库"
git merge ai-nation/ai-nation-local --allow-unrelated-histories -m "🔄 Auto-sync from ai-nation-local" || log "⚠️ 合并冲突"

# 推送
log "📤 推送到 GitLab..."
git push origin master || die "推送失败"

log "✅ GitLab backup completed"
