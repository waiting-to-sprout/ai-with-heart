# 🔑 Token 轮换通知

**时间**: 2026-03-22 19:50 (Asia/Shanghai)
**状态**: ⚠️ 需要新 Token

---

## 问题诊断

**现象**: GitHub 推送失败
**错误**: `Invalid username or token. Password authentication is not supported`
**原因**: 当前 Token 已过期或被撤销

**当前 Token**: `ghp_uc06o...` (08:23 生成)

---

## 解决方案

### 方案 1: 生成新 Token（推荐）

1. 访问：https://github.com/settings/tokens/new
2. Note: `ai-nation-backup-20260322`
3. scopes: 勾选 `repo` 和 `workflow`
4. 点击 **Generate token**
5. 复制新 Token

然后运行：
```bash
export GITHUB_TOKEN="新 Token"
echo "export GITHUB_TOKEN=\"新 Token\"" >> ~/.bashrc
./scripts/setup-zero-friction.sh
```

### 方案 2: 使用自动轮换脚本

```bash
./scripts/auto-token-rotator.sh
```

（会生成授权链接，点击后自动生成新 Token）

---

## 预计耗时

- 生成 Token: 2 分钟
- 更新配置：1 分钟
- **总计**: 3 分钟

---

## 完成后验证

```bash
# 测试推送
cd /home/admin/openclaw/workspace/ai-nation
git push origin ai-nation-local

# 查看状态
cat /home/admin/openclaw/workspace/temp/zero-friction-state.json
```

---

**🦞 Token 轮换后即可恢复全自动备份。**
