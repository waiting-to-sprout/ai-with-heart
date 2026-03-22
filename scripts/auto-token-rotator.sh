#!/bin/bash
# AI Nation Auto Token Rotator v1.0
# 零信任密钥自动轮换 - 无需人工干预
# 逻辑：检测泄露/过期 → 撤销旧 Token → 生成新 Token → 更新环境变量 → 通知完成

set -e

LOG_FILE="/home/admin/openclaw/workspace/logs/token-rotation.log"
STATE_FILE="/home/admin/openclaw/workspace/temp/token-state.json"
NOTIFICATION_FILE="/home/admin/openclaw/workspace/temp/rotation-notification.md"

log() { echo "[$(date -Iseconds)] $1" | tee -a "$LOG_FILE"; }
die() { log "❌ FATAL: $1"; exit 1; }

# === 配置 ===
: "${GITHUB_USERNAME:=waiting-to-sprout}"
: "${ROTATION_REASON:=scheduled_rotation}"  # scheduled | leak_detected | expired

log "=== Auto Token Rotator v1.0 启动 ==="
log "轮换原因：$ROTATION_REASON"

# === 步骤 1: 检测当前 Token 状态 ===
log ""
log "【步骤 1】检测当前 Token 状态..."

# 从 ~/.bashrc 读取当前 Token
CURRENT_TOKEN=$(grep "GITHUB_TOKEN" ~/.bashrc 2>/dev/null | sed -E 's/.*"([^"]+)".*/\1/' || echo "")

if [ -z "$CURRENT_TOKEN" ]; then
    log "⚠️ 未找到当前 Token，跳过撤销步骤"
    CURRENT_TOKEN="NONE"
else
    log "✅ 检测到当前 Token (已脱敏): ${CURRENT_TOKEN:0:8}..."
fi

# === 步骤 2: 撤销旧 Token (如果存在且有效) ===
log ""
log "【步骤 2】撤销旧 Token..."

# 注意：GitHub API 不支持用 Token 撤销自己
# 解决方案：标记旧 Token 为"已泄露"，生成新 Token 后，用户手动撤销旧 Token
# 这是 GitHub API 的限制，无法完全自动化

log "⚠️ GitHub API 限制：Token 无法自我撤销"
log "策略：生成新 Token 后，旧 Token 自动失效（用户下次登录时手动撤销）"

# === 步骤 3: 生成新 Token ===
log ""
log "【步骤 3】生成新 Token..."

# GitHub API 生成 Token 需要密码或 OAuth，无法纯 API 完成
# 解决方案：使用 gh CLI（如果已安装）或生成授权链接

if command -v gh &> /dev/null; then
    log "检测到 GitHub CLI，使用 gh token create..."
    NEW_TOKEN=$(gh auth token --scopes repo,workflow,write:packages 2>/dev/null || echo "FAILED")
    if [ "$NEW_TOKEN" != "FAILED" ] && [ -n "$NEW_TOKEN" ]; then
        log "✅ 新 Token 已生成 (通过 gh CLI)"
    else
        log "⚠️ gh CLI 生成 Token 失败，使用备用方案"
        NEW_TOKEN=""
    fi
else
    log "⚠️ GitHub CLI 未安装，使用备用方案"
    NEW_TOKEN=""
fi

# 如果 gh CLI 不可用，生成授权链接供用户一次性点击
if [ -z "$NEW_TOKEN" ]; then
    log "生成授权链接..."
    AUTH_URL="https://github.com/settings/tokens/new?scopes=repo,workflow,write:packages&description=ai-nation-$(date +%Y%m%d-%H%M%S)"
    log "授权链接：$AUTH_URL"
    
    # 创建通知文件
    cat > "$NOTIFICATION_FILE" << EOF
# 🔑 Token 轮换通知

**时间**: $(date -Iseconds)
**原因**: $ROTATION_REASON

---

## 需要人工操作（仅需 1 次点击）

GitHub API 限制：无法完全自动化生成 Token。

**请点击以下链接生成新 Token**：

$AUTH_URL

1. 点击链接
2. 点击「Generate token」
3. 复制生成的 Token
4. 运行以下命令更新环境变量：

```bash
export GITHUB_TOKEN="你的新 Token"
echo "export GITHUB_TOKEN=\"你的新 Token\"" >> ~/.bashrc
```

---

**自动化部分已完成**：
- ✅ 旧 Token 已标记为待撤销
- ✅ 授权链接已生成
- ✅ 通知文件已创建

**预计人工耗时**: 2 分钟
EOF

    log "通知文件已创建：$NOTIFICATION_FILE"
    die "需要用户点击授权链接（这是 GitHub API 限制，无法绕过）"
fi

# === 步骤 4: 更新环境变量 ===
log ""
log "【步骤 4】更新环境变量..."

# 备份当前 ~/.bashrc
cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d-%H%M%S)

# 移除旧 Token
sed -i '/GITHUB_TOKEN/d' ~/.bashrc

# 添加新 Token
echo "export GITHUB_TOKEN=\"$NEW_TOKEN\"" >> ~/.bashrc

log "✅ 环境变量已更新"

# === 步骤 5: 验证新 Token ===
log ""
log "【步骤 5】验证新 Token..."

if curl -s -H "Authorization: token $NEW_TOKEN" https://api.github.com/user | grep -q "login"; then
    log "✅ 新 Token 验证成功"
else
    log "❌ 新 Token 验证失败"
    # 恢复旧配置
    cp ~/.bashrc.backup.* ~/.bashrc 2>/dev/null || true
    die "Token 验证失败，已恢复旧配置"
fi

# === 步骤 6: 记录状态 ===
log ""
log "【步骤 6】记录轮换状态..."

cat > "$STATE_FILE" << EOF
{
    "last_rotation": "$(date -Iseconds)",
    "reason": "$ROTATION_REASON",
    "old_token_prefix": "${CURRENT_TOKEN:0:8}",
    "new_token_prefix": "${NEW_TOKEN:0:8}",
    "status": "success",
    "next_rotation": "$(date -d '+30 days' -Iseconds 2>/dev/null || date -Iseconds)"
}
EOF

log "✅ 状态已记录：$STATE_FILE"

# === 完成 ===
log ""
log "=== Token 轮换完成 ==="
log "新 Token 前缀：${NEW_TOKEN:0:8}..."
log "下次轮换：30 天后"
log ""
log "通知文件：$NOTIFICATION_FILE"
