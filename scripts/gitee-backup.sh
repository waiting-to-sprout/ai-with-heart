#!/bin/bash
# AI Nation Gitee Backup Script v2.0
# 架构重构：纯环境变量驱动，零本地凭证依赖
# 失败自诊断，零人工询问

set -e

log() { echo "[$(date -Iseconds)] $1"; }
die() { log "❌ FATAL: $1"; exit 1; }

# === 环境变量校验（自诊断）===
: "${GITEE_TOKEN:?die 'GITEE_TOKEN 未设置 - 执行：export GITEE_TOKEN=\"your_token\"'}"
: "${GITEE_USERNAME:=wooden-connection}"
: "${GITEE_REPO:=ai-nation-backup}"
: "${SOURCE_REPO:=/home/admin/openclaw/workspace/ai-nation}"
: "${BACKUP_DIR:=/home/admin/openclaw/workspace/temp/gitee-backup}"

GITEE_URL="https://${GITEE_USERNAME}:${GITEE_TOKEN}@gitee.com/${GITEE_USERNAME}/${GITEE_REPO}.git"

log "=== Gitee Backup v2.0 Start ==="
log "Config: GITEE_USERNAME=$GITEE_USERNAME, GITEE_REPO=$GITEE_REPO"

# === 克隆或更新（自愈逻辑）===
if [ -d "$BACKUP_DIR/.git" ]; then
    log "📁 更新现有备份..."
    cd "$BACKUP_DIR"
    git fetch origin 2>/dev/null || die "Git fetch 失败 - 检查网络或 Token 权限"
    git reset --hard origin/master 2>/dev/null || die "Git reset 失败 - 可能存在未提交变更"
else
    log "📁 克隆备份仓库..."
    mkdir -p "$(dirname "$BACKUP_DIR")"
    cd "$(dirname "$BACKUP_DIR")"
    git clone "$GITEE_URL" gitee-backup || die "克隆失败 - 检查仓库是否存在及 Token 权限"
fi

# === 同步源仓库 ===
log "🔄 同步 ai-nation 内容..."
cd "$BACKUP_DIR"
git remote add ai-nation "$SOURCE_REPO" 2>/dev/null || true
git fetch ai-nation || die "无法访问源仓库：$SOURCE_REPO"
git merge ai-nation/ai-nation-local --allow-unrelated-histories -m "🔄 Auto-sync from ai-nation-local" || log "⚠️ 合并冲突待人工审查"

# === 推送（带重试）===
log "📤 推送到 Gitee..."
for i in 1 2 3; do
    git push origin master && { log "✅ 推送成功"; break; } || {
        log "⚠️ 推送失败 (尝试 $i/3)";
        [ $i -eq 3 ] && die "3 次推送均失败 - 检查远程仓库状态";
        sleep 2;
    }
done

log "✅ Gitee backup completed"
log "=== Gitee Backup v2.0 End ==="
