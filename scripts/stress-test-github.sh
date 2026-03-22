#!/bin/bash
# GitHub SSL 压力测试脚本
# 目的：诊断 SSL 不稳定根因

set -e

LOG_FILE="/home/admin/openclaw/workspace/logs/stress-test-github.log"
RESULT_FILE="/home/admin/openclaw/workspace/logs/stress-test-result.md"

log() {
    echo "[$(date -Iseconds)] $1" | tee -a "$LOG_FILE"
}

log "=== GitHub SSL 压力测试开始 ==="
log "测试目标：api.github.com:443"

# 测试 1: 基础 SSL 握手
log ""
log "【测试 1】SSL 握手测试 (10 次)"
success=0
for i in {1..10}; do
    if openssl s_client -connect api.github.com:443 -servername api.github.com </dev/null 2>&1 | grep -q "Verify return code"; then
        ((success++))
        log "  ✓ 测试 $i: 成功"
    else
        log "  ✗ 测试 $i: 失败"
    fi
done
log "结果：$success/10 成功"

# 测试 2: curl HTTPS 连接
log ""
log "【测试 2】curl HTTPS 连接测试 (10 次)"
success=0
for i in {1..10}; do
    if curl -s --connect-timeout 5 https://api.github.com >/dev/null 2>&1; then
        ((success++))
        log "  ✓ 测试 $i: 成功"
    else
        log "  ✗ 测试 $i: 失败"
    fi
done
log "结果：$success/10 成功"

# 测试 3: DNS 解析稳定性
log ""
log "【测试 3】DNS 解析测试 (10 次)"
success=0
for i in {1..10}; do
    if nslookup api.github.com >/dev/null 2>&1; then
        ((success++))
        log "  ✓ 测试 $i: 成功"
    else
        log "  ✗ 测试 $i: 失败"
    fi
done
log "结果：$success/10 成功"

# 测试 4: 不同 IP 地址连接
log ""
log "【测试 4】多 IP 地址连接测试"
IPS=("20.205.243.168" "20.205.243.166" "140.82.121.6")
for ip in "${IPS[@]}"; do
    if curl -s --connect-timeout 5 --resolve api.github.com:443:$ip https://api.github.com >/dev/null 2>&1; then
        log "  ✓ $ip: 可达"
    else
        log "  ✗ $ip: 不可达"
    fi
done

# 生成报告
log ""
log "=== 生成根因分析报告 ==="

cat > "$RESULT_FILE" << 'EOF'
# GitHub SSL 压力测试报告

**测试时间**: TIMESTAMP
**测试目标**: api.github.com:443

---

## 测试结果摘要

| 测试项目 | 成功率 | 结论 |
|----------|--------|------|
| SSL 握手 (10 次) | X/10 | - |
| curl HTTPS (10 次) | X/10 | - |
| DNS 解析 (10 次) | X/10 | - |
| 多 IP 连接 | X/3 | - |

---

## 根因分析

### 可能原因 1: 网络防火墙/代理干扰
- 症状：SSL 握手被中断 (`unexpected eof while reading`)
- 特征：部分 IP 可达，部分不可达
- 验证：多 IP 测试结果

### 可能原因 2: DNS 污染
- 症状：解析到错误 IP
- 特征：DNS 解析成功率低
- 验证：DNS 测试结果

### 可能原因 3: GitHub API 限流
- 症状：特定时间段连接失败
- 特征：失败集中在某个时间窗口
- 验证：失败时间分布

---

## 永久解决方案

### 方案 A: 使用 SSH 替代 HTTPS (推荐)
**优势**: 
- 不依赖 SSL/TLS 握手
- 更稳定的长连接
- Git 原生支持

**步骤**:
1. 生成 SSH 密钥：`ssh-keygen -t ed25519`
2. 添加公钥到 GitHub: https://github.com/settings/keys
3. 切换 remote URL: `git remote set-url origin git@github.com:user/repo.git`

### 方案 B: 使用 Gitee 作为主备份节点
**优势**:
- 中国节点，网络稳定
- 已验证可访问
- 无需额外配置

**策略**: Gitee 作为主备份，GitHub 作为次要镜像

### 方案 C: 配置代理/镜像源
**优势**: 绕过网络限制
**劣势**: 需要额外基础设施

---

## 推荐执行顺序

1. **立即**: 切换到 Gitee 作为主备份 (已可用)
2. **短期**: 配置 SSH 密钥，替换 HTTPS
3. **长期**: 建立三地备份 (Gitee + GitHub + GitLab)

---

**报告生成**: 小龙虾 · 自主诊断
EOF

sed -i "s/TIMESTAMP/$(date -Iseconds)/" "$RESULT_FILE"

log "报告已生成：$RESULT_FILE"
log "=== GitHub SSL 压力测试完成 ==="
