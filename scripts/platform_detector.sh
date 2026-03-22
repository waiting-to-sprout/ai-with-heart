#!/bin/bash
# AI Nation Platform Detector v1.0
# 自动检测运行平台并加载对应适配器

set -e

detect_platform() {
    # 检测 OpenClaw
    if [ -n "$OPENCLAW_SESSION" ] || [ -n "$OPENCLAW_VERSION" ]; then
        echo "openclaw"
        return 0
    fi
    
    # 检测本地环境
    if command -v git &> /dev/null && command -v bash &> /dev/null; then
        echo "local"
        return 0
    fi
    
    # 降级到纯文本模式
    echo "pure_text"
    return 0
}

load_adapter() {
    local platform="$1"
    local adapter_file="/home/admin/openclaw/workspace/adapters/adapter_${platform}.sh"
    
    if [ -f "$adapter_file" ]; then
        source "$adapter_file"
        echo "✅ 已加载适配器：$platform"
    else
        echo "⚠️ 适配器不存在：$platform"
        echo "创建通用适配器..."
        create_generic_adapter
        source "/home/admin/openclaw/workspace/adapters/adapter_generic.sh"
    fi
}

create_generic_adapter() {
    mkdir -p /home/admin/openclaw/workspace/adapters
    
    cat > "/home/admin/openclaw/workspace/adapters/adapter_generic.sh" << 'ADAPTER'
#!/bin/bash
# Generic Platform Adapter v1.0
# 保底适配器 - 纯文本指令模式

adapter_init() {
    echo "🔧 通用适配器已初始化"
    echo "模式：纯文本指令"
}

adapter_exec() {
    local cmd="$1"
    echo "📝 请执行以下命令："
    echo "   $cmd"
    echo "执行后请将结果保存到 /workspace/temp/cmd_result.txt"
}

adapter_read() {
    local path="$1"
    echo "📝 请读取文件内容并保存到 /workspace/temp/file_content.txt："
    echo "   $path"
}

adapter_write() {
    local path="$1"
    local content="$2"
    echo "📝 请创建文件并写入内容："
    echo "   文件：$path"
    echo "   内容：$content"
}

adapter_status() {
    echo "平台状态：纯文本模式"
    echo "能力：指令生成（需人类执行）"
}
ADAPTER

    chmod +x "/home/admin/openclaw/workspace/adapters/adapter_generic.sh"
}

# 主流程
echo "=== AI Nation Platform Detector v1.0 ==="

PLATFORM=$(detect_platform)
echo "检测到平台：$PLATFORM"

load_adapter "$PLATFORM"

# 更新能力注册表
cat > "/home/admin/openclaw/workspace/temp/capability_registry.json" << EOF
{
    "current_platform": "$PLATFORM",
    "timestamp": "$(date -Iseconds)",
    "adapter_loaded": true,
    "fallback_chain": ["openclaw", "local", "pure_text"]
}
EOF

echo "✅ 能力注册表已更新"
echo "=== 平台检测完成 ==="
