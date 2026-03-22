#!/bin/bash
# Local CLI Platform Adapter v1.0
# 适配本地 CLI 环境

set -e

adapter_init() {
    echo "🔧 本地 CLI 适配器已初始化"
    echo "平台：Local"
    echo "能力：文件读写、命令执行"
}

adapter_exec() {
    local cmd="$1"
    # 直接执行命令
    eval "$cmd"
}

adapter_read() {
    local path="$1"
    # 读取文件
    cat "$path"
}

adapter_write() {
    local path="$1"
    local content="$2"
    # 写入文件
    echo "$content" > "$path"
}

adapter_status() {
    echo "平台状态：本地 CLI"
    echo "能力：标准（无浏览器）"
}

# 导出函数
export -f adapter_init adapter_exec adapter_read adapter_write adapter_status
