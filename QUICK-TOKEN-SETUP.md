# 🔑 Token 快速设置指南

**问题**: 网络不稳定，Token 容易丢失

**解决方案**: 直接复制粘贴到终端，无需保存文件

---

## 步骤（1 分钟）

### 1. 生成 Token

访问：https://github.com/settings/tokens/new

- Note: `ai-nation`
- scopes: 勾选 `repo`
- 点击 **Generate token**
- **立即复制 Token**（显示一次）

### 2. 直接运行

复制下方命令，替换 `你的 Token`：

```bash
export GITHUB_TOKEN="你的 Token"
```

然后运行：

```bash
/home/admin/openclaw/workspace/scripts/setup-zero-friction.sh
```

---

## 如果网络中断

**不要重新生成 Token**！之前的 Token 仍然有效。

只需重新运行：

```bash
export GITHUB_TOKEN="之前的 Token"
./scripts/setup-zero-friction.sh
```

---

## 验证

```bash
# 检查 Token 是否有效
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# 如果返回用户信息，说明 Token 有效
```

---

**🦞 网络不稳定时，Token 只需生成 1 次，可重复使用。**
