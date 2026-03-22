#!/bin/bash
# Pure Text Platform Adapter v1.0
# 纯文本模式 - 保底适配器

set -e

adapter_init() {
    echo "🔧 纯文本适配器已初始化"
    echo "平台：Pure Text"
    echo "能力：指令生成（需人类执行）"
}

adapter_exec() {
    local cmd="$1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📝 请执行以下命令："
    echo ""
    echo "   $cmd"
    echo ""
    echo "执行后请将结果保存到："
    echo "   /workspace/temp/cmd_result.txt"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

adapter_read() {
    local path="$1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📝 请读取文件内容："
    echo ""
    echo "   文件：$path"
    echo ""
    echo "请将内容保存到："
    echo "   /workspace/temp/file_content.txt"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

adapter_write() {
    local path="$1"
    local content="$2"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📝 请创建文件并写入内容："
    echo ""
    echo "   文件：$path"
    echo ""
    echo "   内容："
    echo "$content"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

adapter_status() {
    echo "平台状态：纯文本模式"
    echo "能力：指令生成（需人类执行）"
    echo "降级原因：当前平台不支持自动执行"
}

# 导出函数
export -f adapter_init adapter_exec adapter_read adapter_write adapter_status
