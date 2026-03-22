#!/bin/bash
# AI Nation 安全沙箱 v1.0
# 隔离测试环境，防止生产数据污染
# 原则：所有测试在沙箱中执行，失败不影响主系统

set -e

SANDBOX_DIR="/home/admin/openclaw/workspace/sandbox"
LOG_FILE="/home/admin/openclaw/workspace/logs/sandbox.log"

log() { echo "[$(date -Iseconds)] $1" | tee -a "$LOG_FILE"; }
die() { log "❌ $1"; exit 1; }

# 创建沙箱环境
init_sandbox() {
    log "=== 初始化安全沙箱 ==="
    
    mkdir -p "$SANDBOX_DIR"/{repos,logs,config,temp}
    
    # 创建隔离的 Git 配置
    cat > "$SANDBOX_DIR/config/git-sandbox" << 'GITCONFIG'
[user]
    name = AI Nation Sandbox
    email = sandbox@ai-nation.local
[credential]
    helper = store
    helper = cache --timeout=300
GITCONFIG
    
    log "✅ 沙箱目录已创建：$SANDBOX_DIR"
}

# 在沙箱中执行 Git 操作
sandbox_git_test() {
    local test_name="$1"
    local repo_url="$2"
    local test_dir="$SANDBOX_DIR/temp/$test_name"
    
    log "【沙箱测试】$test_name"
    
    mkdir -p "$test_dir"
    cd "$test_dir"
    git init --quiet
    
    # 使用沙箱 Git 配置
    export GIT_CONFIG="$SANDBOX_DIR/config/git-sandbox"
    
    # 测试连接（不推送真实数据）
    if git ls-remote "$repo_url" >/dev/null 2>&1; then
        log "  ✅ $test_name: 连接成功"
        return 0
    else
        log "  ❌ $test_name: 连接失败"
        return 1
    fi
}

# 自动清理
cleanup_sandbox() {
    log "清理沙箱临时文件..."
    find "$SANDBOX_DIR/temp" -type d -mtime +1 -exec rm -rf {} \; 2>/dev/null || true
    log "✅ 沙箱清理完成"
}

# 主流程
case "${1:-init}" in
    init)
        init_sandbox
        ;;
    test)
        sandbox_git_test "$2" "$3"
        ;;
    cleanup)
        cleanup_sandbox
        ;;
    *)
        echo "用法：$0 {init|test|cleanup}"
        exit 1
        ;;
esac
