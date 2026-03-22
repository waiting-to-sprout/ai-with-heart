#!/bin/bash
# AI Nation 安全汇报脚本 v1.0
# 自动脱敏：过滤所有 Token/凭证/密钥
# 原则：汇报中零敏感信息泄露

set -e

REPORT_FILE="/home/admin/openclaw/workspace/temp/safe-report-$(date +%Y%m%d-%H%M%S).md"

# 脱敏函数
sanitize() {
    local text="$1"
    # 过滤 GitHub Token (ghp_xxx, gho_xxx, ghu_xxx, ghs_xxx, ghr_xxx)
    text=$(echo "$text" | sed -E 's/gh[pours]_[A-Za-z0-9]{36}/[REDACTED_GITHUB_TOKEN]/g')
    # 过滤 Gitee Token (32 位 hex)
    text=$(echo "$text" | sed -E 's/[a-f0-9]{32}/[REDACTED_GITEE_TOKEN]/g')
    # 过滤 GitLab Token (glpat-xxx)
    text=$(echo "$text" | sed -E 's/glpat-[A-Za-z0-9\-]{20,}/[REDACTED_GITLAB_TOKEN]/g')
    # 过滤 URL 中的凭证
    text=$(echo "$text" | sed -E 's/https:\/\/[^:]+:[^@]+@/https:\/\/[CREDENTIALS_REMOVED]@/g')
    echo "$text"
}

# 生成汇报（自动脱敏）
generate_report() {
    cat << 'EOF'
# AI Nation 安全汇报

**生成时间**: TIMESTAMP
**安全级别**: 已脱敏

---

## 当前状态

EOF

    # 添加系统状态（脱敏后）
    echo "### 环境变量检查"
    if [ -n "$GITHUB_TOKEN" ]; then
        echo "- GITHUB_TOKEN: ✅ 已配置 ([REDACTED])"
    else
        echo "- GITHUB_TOKEN: ❌ 未配置"
    fi
    
    if [ -n "$GITEE_TOKEN" ]; then
        echo "- GITEE_TOKEN: ✅ 已配置 ([REDACTED])"
    else
        echo "- GITEE_TOKEN: ❌ 未配置"
    fi
    
    echo ""
    echo "### 备份状态"
    echo "（此处添加备份状态，所有敏感信息已自动过滤）"
}

# 主流程
log "=== 安全汇报生成开始 ==="
log "输出文件：$REPORT_FILE"

# 生成并脱敏
raw_report=$(generate_report)
safe_report=$(sanitize "$raw_report")

# 替换时间戳
safe_report=$(echo "$safe_report" | sed "s/TIMESTAMP/$(date -Iseconds)/")

# 写入文件
echo "$safe_report" > "$REPORT_FILE"

log "✅ 安全汇报已生成（已脱敏）"
log "文件：$REPORT_FILE"
log "=== 安全汇报生成完成 ==="
