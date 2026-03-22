# GitLab 人工接入指南

**目的**: 创建 GitLab 备份节点，实现三地容灾

**预计耗时**: 10 分钟

---

## 步骤 1: 注册/登录 GitLab

1. 访问 https://gitlab.com/users/sign_in
2. 点击 "Sign in with GitHub" (使用现有 GitHub 账号)
3. 授权 GitLab 访问 GitHub 账号

**或** 直接注册：
1. 访问 https://gitlab.com/users/sign_up
2. 使用邮箱注册

---

## 步骤 2: 创建仓库

1. 点击 "New project" (右上角 + 号)
2. 选择 "Create blank project"
3. 填写：
   - **Project name**: `ai-nation-backup`
   - **Project slug**: `ai-nation-backup`
   - **Visibility**: Public 或 Private
4. 点击 "Create project"

---

## 步骤 3: 获取 Access Token

1. 访问 https://gitlab.com/-/profile/personal_access_tokens
2. 点击 "Add new token"
3. 填写：
   - **Token name**: `ai-nation-backup`
   - **Expiration date**: 2027-01-01 (或更远)
   - **Select scopes**: 勾选 `api`, `write_repository`
4. 点击 "Create personal access token"
5. **立即复制 Token** (只显示一次)

---

## 步骤 4: 配置环境变量

编辑 `~/.bashrc`，添加：
```bash
export GITLAB_TOKEN="your_token_here"
export GITLAB_USERNAME="your_username"
export GITLAB_REPO="ai-nation-backup"
```

---

## 步骤 5: 测试推送

```bash
cd /home/admin/openclaw/workspace/ai-nation
git remote add gitlab https://oauth2:YOUR_TOKEN@gitlab.com/your_username/ai-nation-backup.git
git push -u gitlab ai-nation-local
```

---

## 验证

访问 https://gitlab.com/your_username/ai-nation-backup
确认提交记录已同步。

---

**有问题？** 等待下一个 30 分钟窗口期询问。
