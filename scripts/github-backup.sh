#!/bin/bash
# AI Nation GitHub Backup Script v2.0
# 架构重构：纯环境变量驱动，零本地凭证依赖
# 失败自诊断，零人工询问

set -e

log() { echo "[$(date -Iseconds)] $1"; }
die() { log "❌ FATAL: $1"; exit 1; }

# === 环境变量校验（自诊断）===
: "${GITHUB_TOKEN:?die 'GITHUB_TOKEN 未设置 - 执行：export GITHUB_TOKEN=\"your_token\"'}"
: "${GITHUB_USERNAME:=waiting-to-sprout}"
: "${GITHUB_REPO:=ai-with-heart}"
: "${SOURCE_REPO:=/home/admin/openclaw/workspace/ai-nation}"
: "${BACKUP_BRANCH:=ai-nation-local}"
: "${BACKUP_DIR:=/home/admin/openclaw/workspace/temp/github-backup}"

GITHUB_URL="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${GITHUB_REPO}.git"

log "=== GitHub Backup v2.0 Start ==="
log "Config: GITHUB_USERNAME=$GITHUB_USERNAME, BACKUP_BRANCH=$BACKUP_BRANCH"

# === 克隆或更新（自愈逻辑）===
if [ -d "$BACKUP_DIR/.git" ]; then
    log "📁 更新现有备份..."
    cd "$BACKUP_DIR"
    git fetch origin 2>/dev/null || die "Git fetch 失败 - 检查网络或 Token 权限"
    git reset --hard origin/$BACKUP_BRANCH 2>/dev/null || die "Git reset 失败 - 分支可能不存在"
else
    log "📁 克隆备份仓库..."
    mkdir -p "$(dirname "$BACKUP_DIR")"
    cd "$(dirname "$BACKUP_DIR")"
    git clone --branch $BACKUP_BRANCH "$GITHUB_URL" github-backup 2>/dev/null || {
        log "⚠️ 分支不存在，克隆默认分支后切换..."
        git clone "$GITHUB_URL" github-backup || die "克隆失败 - 检查仓库是否存在及 Token 权限"
        cd github-backup
        git checkout -b $BACKUP_BRANCH || true
    }
fi

# === 同步源仓库 ===
log "🔄 同步 ai-nation 内容..."
cd "$BACKUP_DIR"
git remote add ai-nation "$SOURCE_REPO" 2>/dev/null || true
git fetch ai-nation || die "无法访问源仓库：$SOURCE_REPO"
git merge ai-nation/$BACKUP_BRANCH --allow-unrelated-histories -m "🔄 Auto-sync from $BACKUP_BRANCH" || log "⚠️ 合并冲突待人工审查"

# === 推送（带重试）===
log "📤 推送到 GitHub..."
for i in 1 2 3; do
    git push origin $BACKUP_BRANCH && { log "✅ 推送成功"; break; } || {
        log "⚠️ 推送失败 (尝试 $i/3) - 可能是 SSL 网络问题";
        [ $i -eq 3 ] && die "3 次推送均失败 - 检查网络连接或 GitHub API 状态";
        sleep 2;
    }
done

log "✅ GitHub backup completed"
log "=== GitHub Backup v2.0 End ==="
