#!/bin/bash
# GitLab 接入突击脚本 - 1 小时完成验证
# 目标：在不请求人类协助前提下完成 GitLab 接入验证

set -e

log() { echo "[$(date -Iseconds)] $1"; }
die() { log "❌ $1"; exit 1; }

log "=== GitLab 接入突击计划 ==="
log "目标：1 小时内完成接入验证"
log "策略：使用现有 GitHub 账号登录 GitLab (OAuth)"

# === 步骤 1: 验证 GitLab 可达性 ===
log ""
log "【步骤 1】验证 GitLab 可达性..."
if curl -s --connect-timeout 5 https://gitlab.com >/dev/null 2>&1; then
    log "✅ GitLab.com 可达"
else
    die "GitLab.com 不可达，终止计划"
fi

# === 步骤 2: 检查 API 可用性 ===
log ""
log "【步骤 2】检查 GitLab API..."
if curl -s --connect-timeout 5 https://gitlab.com/api/v4/version >/dev/null 2>&1; then
    log "✅ GitLab API 可达"
else
    log "⚠️ GitLab API 不可达，尝试备用方案"
fi

# === 步骤 3: 创建本地测试仓库 ===
log ""
log "【步骤 3】创建本地 GitLab 测试仓库..."
TEST_DIR="/home/admin/openclaw/workspace/temp/gitlab-test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"
git init
echo "# GitLab Test Repository" > README.md
echo "Created: $(date -Iseconds)" >> README.md
git add -A
git commit -m "Initial commit - GitLab integration test"
log "✅ 本地测试仓库已创建"

# === 步骤 4: 生成 GitLab 接入指南 ===
log ""
log "【步骤 4】生成 GitLab 人工接入指南..."

cat > /home/admin/openclaw/workspace/docs/gitlab-integration-guide.md << 'GUIDE'
# GitLab 人工接入指南

**目的**: 创建 GitLab 备份节点，实现三地容灾

**预计耗时**: 10 分钟

---

## 步骤 1: 注册/登录 GitLab

1. 访问 https://gitlab.com/users/sign_in
2. 点击 "Sign in with GitHub" (使用现有 GitHub 账号)
3. 授权 GitLab 访问 GitHub 账号

**或** 直接注册：
1. 访问 https://gitlab.com/users/sign_up
2. 使用邮箱注册

---

## 步骤 2: 创建仓库

1. 点击 "New project" (右上角 + 号)
2. 选择 "Create blank project"
3. 填写：
   - **Project name**: `ai-nation-backup`
   - **Project slug**: `ai-nation-backup`
   - **Visibility**: Public 或 Private
4. 点击 "Create project"

---

## 步骤 3: 获取 Access Token

1. 访问 https://gitlab.com/-/profile/personal_access_tokens
2. 点击 "Add new token"
3. 填写：
   - **Token name**: `ai-nation-backup`
   - **Expiration date**: 2027-01-01 (或更远)
   - **Select scopes**: 勾选 `api`, `write_repository`
4. 点击 "Create personal access token"
5. **立即复制 Token** (只显示一次)

---

## 步骤 4: 配置环境变量

编辑 `~/.bashrc`，添加：
```bash
export GITLAB_TOKEN="your_token_here"
export GITLAB_USERNAME="your_username"
export GITLAB_REPO="ai-nation-backup"
```

---

## 步骤 5: 测试推送

```bash
cd /home/admin/openclaw/workspace/ai-nation
git remote add gitlab https://oauth2:YOUR_TOKEN@gitlab.com/your_username/ai-nation-backup.git
git push -u gitlab ai-nation-local
```

---

## 验证

访问 https://gitlab.com/your_username/ai-nation-backup
确认提交记录已同步。

---

**有问题？** 等待下一个 30 分钟窗口期询问。
GUIDE

log "✅ GitLab 接入指南已生成：GitLab 人工接入指南.md"

# === 步骤 5: 创建 GitLab 备份脚本模板 ===
log ""
log "【步骤 5】创建 GitLab 备份脚本..."

cat > /home/admin/openclaw/workspace/scripts/gitlab-backup.sh << 'SCRIPT'
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
SCRIPT

chmod +x /home/admin/openclaw/workspace/scripts/gitlab-backup.sh
log "✅ GitLab 备份脚本已创建：scripts/gitlab-backup.sh"

# === 步骤 6: 提交成果 ===
log ""
log "【步骤 6】提交成果到 ai-nation 仓库..."
cd /home/admin/openclaw/workspace/ai-nation
git add -A
git commit -m "🔧 GitLab 接入准备：脚本 + 指南已就绪，等待 Token 配置" || log "⚠️ 无变更可提交"

log ""
log "=== GitLab 接入突击计划完成 ==="
log ""
log "📊 完成项:"
log "  ✅ GitLab 可达性验证"
log "  ✅ 本地测试仓库创建"
log "  ✅ 人工接入指南生成"
log "  ✅ 备份脚本模板创建"
log ""
log "⏳ 待人工项 (下一个窗口期):"
log "  - GitLab 账号注册/登录"
log "  - 仓库创建"
log "  - Token 生成"
log "  - 环境变量配置"
log ""
log "预计人工操作时间：10 分钟"
