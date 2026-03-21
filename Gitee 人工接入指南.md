# 🇨🇳 Gitee 人工接入指南

**目的**: 创建 Gitee 备份节点，实现"GitHub + Gitee"双云端容灾

**预计耗时**: 5 分钟

---

## 步骤 1: 创建仓库

1. 访问 https://gitee.com/new
2. 填写以下信息：
   - **仓库名称**: `ai-nation-backup`
   - **仓库介绍**: AI Nation 备份仓库（容灾节点）
   - **可见性**: 公开 或 私有 均可
   - **初始化选项**: 不勾选任何初始化（不要添加 README/.gitignore）
3. 点击「创建」

---

## 步骤 2: 获取 Token

1. 访问 https://gitee.com/profile/personal_access_tokens
2. 点击「生成新的 Token」
3. 填写：
   - **标题**: `ai-nation-backup`
   - **权限**: 勾选 `repo`（仓库读写权限）
4. 点击「提交」
5. **立即复制 Token**（只显示一次，关闭后无法再查看）

---

## 步骤 3: 填写凭证文件

1. 打开文件：`/home/admin/openclaw/workspace/.gitee-credentials`
2. 将以下内容中的 `YOUR_GITEE_TOKEN_HERE` 替换为你刚复制的 Token：

```
https://waiting-to-sprout:YOUR_GITEE_TOKEN_HERE@gitee.com
```

例如，如果你的 Token 是 `abc123xyz`，则改为：
```
https://waiting-to-sprout:abc123xyz@gitee.com
```

3. 保存文件

---

## 验证

执行以下命令，看到 `✅ Gitee backup completed` 即成功：

```bash
cd /home/admin/openclaw/workspace
./scripts/gitee-backup.sh
```

---

## 完成后的效果

- ✅ 数据同时存在于 GitHub 和 Gitee 两个云端
- ✅ 中国节点访问更快、更稳定
- ✅ 实现真正的"双活容灾"

---

**有问题？** 随时询问小龙虾 🦞
