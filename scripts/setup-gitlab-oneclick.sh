#!/bin/bash
# AI Nation GitLab One-Click Setup v1.0
# 一键接入 - 将 8 分钟人工操作压缩为 1 条命令
# 整合流程：检查环境 → 引导登录 → 获取 Token → 创建仓库 → 配置远程

set -e

LOG_FILE="/home/admin/openclaw/workspace/logs/gitlab-oneclick.log"
RESULT_FILE="/home/admin/openclaw/workspace/temp/gitlab-setup-result.md"

log() { echo "[$(date -Iseconds)] $1" | tee -a "$LOG_FILE"; }
die() { log "❌ FATAL: $1"; exit 1; }

log "=== GitLab One-Click Setup v1.0 启动 ==="

# === 步骤 1: 检查环境 ===
log ""
log "【步骤 1】检查环境..."

# 检查 GitLab CLI
if command -v glab &> /dev/null; then
    log "✅ GitLab CLI (glab) 已安装"
    GLAB_AVAILABLE=true
else
    log "⚠️ GitLab CLI 未安装，尝试安装..."
    # 尝试自动安装
    if command -v apt &> /dev/null; then
        apt install -y glab 2>/dev/null && log "✅ glab 已安装" && GLAB_AVAILABLE=true || GLAB_AVAILABLE=false
    elif command -v yum &> /dev/null; then
        yum install -y glab 2>/dev/null && log "✅ glab 已安装" && GLAB_AVAILABLE=true || GLAB_AVAILABLE=false
    else
        log "⚠️ 无法自动安装 glab，使用备用方案"
        GLAB_AVAILABLE=false
    fi
fi

# 检查现有 Token
GITLAB_TOKEN=$(grep "GITLAB_TOKEN" ~/.bashrc 2>/dev/null | sed -E 's/.*"([^"]+)".*/\1/' || echo "")
if [ -n "$GITLAB_TOKEN" ]; then
    log "✅ 检测到现有 GitLab Token"
    TOKEN_EXISTS=true
else
    log "⏳ 未检测到 GitLab Token"
    TOKEN_EXISTS=false
fi

# === 步骤 2: 认证引导 ===
log ""
log "【步骤 2】认证引导..."

if [ "$GLAB_AVAILABLE" = true ]; then
    log "使用 GitLab CLI 进行认证..."
    
    # 尝试自动认证（需要用户交互）
    if glab auth login --hostname gitlab.com --web 2>/dev/null; then
        log "✅ GitLab CLI 认证成功"
        AUTH_SUCCESS=true
    else
        log "⚠️ GitLab CLI 认证需要用户交互"
        AUTH_SUCCESS=false
    fi
else
    log "⚠️ GitLab CLI 不可用，使用浏览器认证方案"
    AUTH_SUCCESS=false
fi

# 如果自动认证失败，生成一次性授权链接
if [ "$AUTH_SUCCESS" = false ]; then
    log ""
    log "生成授权链接..."
    
    # GitLab OAuth 授权链接
    CLIENT_ID="gitlab-cli"  # GitLab 官方 CLI 使用
    REDIRECT_URI="http://127.0.0.1:8080"
    AUTH_URL="https://gitlab.com/oauth/authorize?client_id=$CLIENT_ID&redirect_uri=$REDIRECT_URI&response_type=token&scope=api+write_repository"
    
    log "授权链接：$AUTH_URL"
    
    # 创建引导文件
    cat > /home/admin/openclaw/workspace/temp/gitlab-auth-guide.md << EOF
# GitLab 一键接入 - 认证引导

**时间**: $(date -Iseconds)

---

## 方案 A: 使用 GitLab CLI（推荐）

```bash
# 安装 glab（如果未安装）
# Ubuntu/Debian:
sudo apt install -y glab

# 或从官方下载：
# https://gitlab.com/gitlab-org/cli/-/releases

# 认证登录
glab auth login --hostname gitlab.com --web
```

---

## 方案 B: 手动获取 Token

1. 访问：https://gitlab.com/-/profile/personal_access_tokens
2. 点击「Add new token」
3. 填写：
   - **Token name**: `ai-nation-backup`
   - **Expiration date**: 2027-01-01
   - **Select scopes**: 勾选 \`api\`, \`write_repository\`
4. 点击「Create personal access token」
5. 复制 Token

然后运行：
```bash
export GITLAB_TOKEN="你的 Token"
echo "export GITLAB_TOKEN=\"你的 Token\"" >> ~/.bashrc
```

---

**完成后运行**：
```bash
/home/admin/openclaw/workspace/scripts/setup-gitlab-oneclick.sh --continue
```
EOF

    log "认证引导已创建：/home/admin/openclaw/workspace/temp/gitlab-auth-guide.md"
fi

# === 步骤 3: 创建仓库 ===
log ""
log "【步骤 3】创建 GitLab 仓库..."

if [ -n "$GITLAB_TOKEN" ]; then
    # 检查仓库是否已存在
    REPO_EXISTS=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "https://gitlab.com/api/v4/projects?search=ai-nation-backup" 2>/dev/null | grep -c "ai-nation-backup" || echo "0")
    
    if [ "$REPO_EXISTS" -gt 0 ]; then
        log "⚠️ 仓库已存在，跳过创建"
        REPO_CREATED=false
    else
        # 创建仓库
        CREATE_RESPONSE=$(curl -s -X POST \
            --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
            --header "Content-Type: application/json" \
            "https://gitlab.com/api/v4/projects" \
            -d "{\"name\":\"ai-nation-backup\",\"description\":\"AI Nation Backup Repository\",\"visibility\":\"private\",\"initialize_with_readme\":true}" 2>/dev/null || echo "FAILED")
        
        if echo "$CREATE_RESPONSE" | grep -q "id"; then
            log "✅ GitLab 仓库已创建"
            REPO_CREATED=true
        else
            log "⚠️ 仓库创建失败：$CREATE_RESPONSE"
            REPO_CREATED=false
        fi
    fi
else
    log "⏳ 等待 Token 配置"
    REPO_CREATED=false
fi

# === 步骤 4: 配置远程地址 ===
log ""
log "【步骤 4】配置远程地址..."

if [ -n "$GITLAB_TOKEN" ]; then
    GITLAB_USERNAME=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "https://gitlab.com/api/v4/user" 2>/dev/null | grep -o '"username":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
    
    if [ "$GITLAB_USERNAME" != "unknown" ]; then
        log "✅ GitLab 用户名：$GITLAB_USERNAME"
        
        # 更新环境变量
        if ! grep -q "GITLAB_USERNAME" ~/.bashrc; then
            echo "export GITLAB_USERNAME=\"$GITLAB_USERNAME\"" >> ~/.bashrc
            log "✅ GITLAB_USERNAME 已添加到 ~/.bashrc"
        fi
        
        # 配置 ai-nation 仓库的远程地址
        cd /home/admin/openclaw/workspace/ai-nation
        if ! git remote | grep -q "gitlab"; then
            git remote add gitlab "https://oauth2:$GITLAB_TOKEN@gitlab.com/$GITLAB_USERNAME/ai-nation-backup.git"
            log "✅ GitLab remote 已添加"
        else
            git remote set-url gitlab "https://oauth2:$GITLAB_TOKEN@gitlab.com/$GITLAB_USERNAME/ai-nation-backup.git"
            log "✅ GitLab remote 已更新"
        fi
    else
        log "⚠️ 无法获取 GitLab 用户名"
    fi
else
    log "⏳ 等待 Token 配置"
fi

# === 步骤 5: 测试推送 ===
log ""
log "【步骤 5】测试推送..."

if [ -n "$GITLAB_TOKEN" ] && [ "$REPO_CREATED" != "false" ]; then
    cd /home/admin/openclaw/workspace/ai-nation
    if git push gitlab ai-nation-local 2>&1 | tee -a "$LOG_FILE"; then
        log "✅ GitLab 推送成功"
        PUSH_SUCCESS=true
    else
        log "⚠️ GitLab 推送失败"
        PUSH_SUCCESS=false
    fi
else
    log "⏳ 等待配置完成"
    PUSH_SUCCESS=false
fi

# === 生成结果报告 ===
log ""
log "【步骤 6】生成结果报告..."

cat > "$RESULT_FILE" << EOF
# GitLab 一键接入结果

**时间**: $(date -Iseconds)
**脚本**: setup-gitlab-oneclick.sh

---

## 执行状态

| 步骤 | 状态 | 说明 |
|------|------|------|
| 环境检查 | ✅ 完成 | glab: $([ "$GLAB_AVAILABLE" = true ] && echo "已安装" || echo "未安装") |
| 认证引导 | $([ "$AUTH_SUCCESS" = true ] && echo "✅ 成功" || echo "⏳ 待人工") | $( [ "$AUTH_SUCCESS" = true ] && echo "CLI 认证成功" || echo "需要用户认证" ) |
| 仓库创建 | $([ "$REPO_CREATED" = true ] && echo "✅ 成功" || echo "⏳ 待认证") | - |
| 远程配置 | $([ -n "$GITLAB_TOKEN" ] && echo "✅ 完成" || echo "⏳ 待 Token") | - |
| 推送测试 | $([ "$PUSH_SUCCESS" = true ] && echo "✅ 成功" || echo "⏳ 待配置") | - |

---

## 下一步

EOF

if [ "$PUSH_SUCCESS" = true ]; then
    cat >> "$RESULT_FILE" << 'SUCCESS'
🎉 **GitLab 接入已完成！**

所有步骤已成功执行，GitLab 节点现已上线。
SUCCESS
else
    cat >> "$RESULT_FILE" << 'PENDING'
**需要完成认证**：

1. 打开引导文件：`/home/admin/openclaw/workspace/temp/gitlab-auth-guide.md`
2. 按照指引完成认证
3. 重新运行：`./scripts/setup-gitlab-oneclick.sh --continue`

**预计剩余时间**: 2 分钟
PENDING
fi

log "✅ 结果报告已生成：$RESULT_FILE"

# === 完成 ===
log ""
log "=== GitLab One-Click Setup 完成 ==="
log ""
log "📊 状态总结:"
log "  环境检查：完成"
log "  认证状态：$([ "$AUTH_SUCCESS" = true ] && echo "✅ 已认证" || echo "⏳ 待认证")"
log "  仓库状态：$([ "$REPO_CREATED" = true ] && echo "✅ 已创建" || echo "⏳ 待创建")"
log "  推送状态：$([ "$PUSH_SUCCESS" = true ] && echo "✅ 已推送" || echo "⏳ 待推送")"
log ""
log "结果文件：$RESULT_FILE"
log "引导文件：/home/admin/openclaw/workspace/temp/gitlab-auth-guide.md"
