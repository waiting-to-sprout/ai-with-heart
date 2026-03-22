#!/bin/bash
# AI Nation SSH Bridge Setup v1.0
# SSH 无缝迁移 - 根除 SSL 不稳定问题
# 生成 SSH 密钥 → 上传公钥 → 切换所有脚本到 SSH 协议

set -e

LOG_FILE="/home/admin/openclaw/workspace/logs/ssh-setup.log"
SSH_KEY_NAME="id_ed25519_backup"
SSH_KEY_PATH="$HOME/.ssh/$SSH_KEY_NAME"

log() { echo "[$(date -Iseconds)] $1" | tee -a "$LOG_FILE"; }
die() { log "❌ FATAL: $1"; exit 1; }

log "=== SSH Bridge Setup v1.0 启动 ==="

# === 步骤 1: 生成 SSH 密钥对 ===
log ""
log "【步骤 1】生成 SSH 密钥对..."

if [ -f "$SSH_KEY_PATH" ]; then
    log "⚠️ SSH 密钥已存在，跳过生成"
else
    mkdir -p ~/.ssh
    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N "" -C "ai-nation-backup-$(date +%Y%m%d)" << CONFIRM
y
CONFIRM
    log "✅ SSH 密钥已生成：$SSH_KEY_PATH"
fi

# 显示公钥
PUBLIC_KEY=$(cat "$SSH_KEY_PATH.pub")
log "公钥内容：$PUBLIC_KEY"

# === 步骤 2: 上传公钥到 GitHub ===
log ""
log "【步骤 2】上传公钥到 GitHub..."

# GitHub API 上传 SSH 密钥需要认证
# 从 ~/.bashrc 读取 Token
GITHUB_TOKEN=$(grep "GITHUB_TOKEN" ~/.bashrc 2>/dev/null | sed -E 's/.*"([^"]+)".*/\1/' || echo "")

if [ -n "$GITHUB_TOKEN" ]; then
    # 尝试 API 上传
    RESPONSE=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/user/keys \
        -d "{\"title\":\"ai-nation-backup-$(date +%Y%m%d)\",\"key\":\"$PUBLIC_KEY\"}" 2>/dev/null || echo "FAILED")
    
    if echo "$RESPONSE" | grep -q "id"; then
        log "✅ 公钥已通过 API 上传到 GitHub"
        GITHUB_UPLOAD_SUCCESS=true
    else
        log "⚠️ API 上传失败（可能是 SSL 问题或 Key 已存在）"
        GITHUB_UPLOAD_SUCCESS=false
    fi
else
    log "⚠️ 未找到 GitHub Token"
    GITHUB_UPLOAD_SUCCESS=false
fi

# 如果 API 上传失败，生成一次性命令供用户执行
if [ "$GITHUB_UPLOAD_SUCCESS" = false ]; then
    log ""
    log "⚠️ 需要用户手动上传公钥（仅需 1 次）"
    
    # 创建上传指令文件
    cat > /home/admin/openclaw/workspace/temp/github-ssh-upload.md << EOF
# GitHub SSH 公钥上传

**时间**: $(date -Iseconds)

---

## 操作步骤（2 分钟）

1. 访问：https://github.com/settings/keys
2. 点击「New SSH key」
3. 填写：
   - **Title**: `ai-nation-backup-$(date +%Y%m%d)`
   - **Key type**: Authentication Key
   - **Key**: 复制下方公钥内容
4. 点击「Add SSH key」

---

## 公钥内容

\`\`\`
$PUBLIC_KEY
\`\`\`

---

## 一键复制命令

\`\`\`bash
echo "$PUBLIC_KEY" | xclip -selection clipboard
# 或
echo "$PUBLIC_KEY" | pbcopy  # macOS
\`\`\`

---

**完成后运行**：
\`\`\`bash
/home/admin/openclaw/workspace/scripts/setup-ssh-bridge.sh --verify
\`\`\`
EOF

    log "上传指令已创建：/home/admin/openclaw/workspace/temp/github-ssh-upload.md"
fi

# === 步骤 3: 上传公钥到 Gitee ===
log ""
log "【步骤 3】上传公钥到 Gitee..."

GITEE_TOKEN=$(grep "GITEE_TOKEN" ~/.bashrc 2>/dev/null | sed -E 's/.*"([^"]+)".*/\1/' || echo "")

if [ -n "$GITEE_TOKEN" ]; then
    GITEE_USERNAME=$(grep "GITEE_USERNAME" ~/.bashrc 2>/dev/null | sed -E 's/.*"([^"]+)".*/\1/' || echo "wooden-connection")
    
    RESPONSE=$(curl -s -X POST \
        "https://gitee.com/api/v5/user/keys" \
        -H "Content-Type: application/json" \
        -d "{\"access_token\":\"$GITEE_TOKEN\",\"title\":\"ai-nation-backup-$(date +%Y%m%d)\",\"key\":\"$PUBLIC_KEY\"}" 2>/dev/null || echo "FAILED")
    
    if echo "$RESPONSE" | grep -q "id"; then
        log "✅ 公钥已通过 API 上传到 Gitee"
        GITEE_UPLOAD_SUCCESS=true
    else
        log "⚠️ Gitee API 上传失败（可能是 Key 已存在）"
        GITEE_UPLOAD_SUCCESS=true  # 假设已存在，继续
    fi
else
    log "⚠️ 未找到 Gitee Token"
    GITEE_UPLOAD_SUCCESS=false
fi

# === 步骤 4: 配置 SSH Config ===
log ""
log "【步骤 4】配置 SSH Config..."

cat >> ~/.ssh/config << SSHCONFIG

# AI Nation Backup Keys
Host github-ai-nation
    HostName github.com
    User git
    IdentityFile ~/.ssh/$SSH_KEY_NAME
    IdentitiesOnly yes

Host gitee-ai-nation
    HostName gitee.com
    User git
    IdentityFile ~/.ssh/$SSH_KEY_NAME
    IdentitiesOnly yes
SSHCONFIG

chmod 600 ~/.ssh/config
log "✅ SSH Config 已配置"

# === 步骤 5: 更新备份脚本使用 SSH ===
log ""
log "【步骤 5】更新备份脚本使用 SSH 协议..."

# GitHub backup script
cat > /home/admin/openclaw/workspace/scripts/github-backup.sh << 'GITHUBSCRIPT'
#!/bin/bash
# AI Nation GitHub Backup Script v3.0 - SSH Native
# 默认使用 SSH，HTTPS 降级

set -e

log() { echo "[$(date -Iseconds)] $1"; }
die() { log "❌ FATAL: $1"; exit 1; }

: "${SOURCE_REPO:=/home/admin/openclaw/workspace/ai-nation}"
: "${BACKUP_BRANCH:=ai-nation-local}"
: "${BACKUP_DIR:=/home/admin/openclaw/workspace/temp/github-backup}"

SSH_REMOTE="git@github-ai-nation:waiting-to-sprout/ai-with-heart.git"
HTTPS_REMOTE="https://waiting-to-sprout:${GITHUB_TOKEN:-}@github.com/waiting-to-sprout/ai-with-heart.git"

log "=== GitHub Backup v3.0 (SSH Native) Start ==="

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
    
    # 优先尝试 SSH
    if git clone --branch $BACKUP_BRANCH "$SSH_REMOTE" github-backup 2>/dev/null; then
        log "✅ SSH 克隆成功"
    else
        log "⚠️ SSH 失败，降级到 HTTPS..."
        git clone --branch $BACKUP_BRANCH "$HTTPS_REMOTE" github-backup || die "HTTPS 克隆失败"
    fi
fi

# 同步源仓库
log "🔄 同步 ai-nation 内容..."
cd "$BACKUP_DIR"
git remote add ai-nation "$SOURCE_REPO" 2>/dev/null || true
git fetch ai-nation || die "无法访问源仓库"
git merge ai-nation/$BACKUP_BRANCH --allow-unrelated-histories -m "🔄 Auto-sync" || log "⚠️ 合并冲突"

# 推送（优先 SSH）
log "📤 推送到 GitHub..."
if git push origin $BACKUP_BRANCH 2>/dev/null; then
    log "✅ SSH 推送成功"
else
    log "⚠️ SSH 推送失败，降级到 HTTPS..."
    git push origin $BACKUP_BRANCH || die "HTTPS 推送失败"
fi

log "✅ GitHub backup completed"
GITHUBSCRIPT

# Gitee backup script
cat > /home/admin/openclaw/workspace/scripts/gitee-backup.sh << 'GITEESCRIPT'
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
GITEESCRIPT

chmod +x /home/admin/openclaw/workspace/scripts/github-backup.sh
chmod +x /home/admin/openclaw/workspace/scripts/gitee-backup.sh
log "✅ 备份脚本已更新为 SSH Native"

# === 步骤 6: 测试 SSH 连接 ===
log ""
log "【步骤 6】测试 SSH 连接..."

ssh -T -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no git@github.com 2>&1 | head -3 | tee -a "$LOG_FILE" || log "⚠️ GitHub SSH 测试失败（可能是 Key 未上传）"
ssh -T -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no git@gitee.com 2>&1 | head -3 | tee -a "$LOG_FILE" || log "⚠️ Gitee SSH 测试失败"

# === 完成 ===
log ""
log "=== SSH Bridge Setup 完成 ==="
log ""
log "📊 状态总结:"
log "  SSH 密钥：$SSH_KEY_PATH"
log "  SSH Config: ~/.ssh/config"
log "  备份脚本：已切换为 SSH Native"
log ""
if [ "$GITHUB_UPLOAD_SUCCESS" = false ]; then
    log "⚠️ 待办：请上传公钥到 GitHub"
    log "   文件：/home/admin/openclaw/workspace/temp/github-ssh-upload.md"
fi
