# 📤 推送到 GitHub 指南

## 现状

✅ 代码已经准备好
✅ 已经 commit
✅ remote 已配置

❌ GitHub 不支持密码直接登录，需要用 Token

---

## 🔑 第一步：生成 Personal Access Token

1. **登录 GitHub**: https://github.com/login
   - 账号：`3188549670@qq.com`
   - 密码：`Spf123456#`

2. **进入 Token 设置页面**: https://github.com/settings/tokens

3. **点击 "Generate new token"** → 选择 "Classic"

4. **填写信息**:
   - Note: `AI with Heart - 2026-03-17`
   - Expiration: `No expiration` (或选 1 年)
   - Scopes: 勾选 **`repo`** (完整控制仓库)

5. **点击 "Generate token"**

6. **复制生成的 Token**（以 `ghp_` 开头）
   - ⚠️ **只显示一次！** 复制后保存好

---

## 📤 第二步：推送到 GitHub

### 方法 A: 使用 Token 推送（推荐）

打开终端，运行：

```bash
cd /home/admin/openclaw/workspace/ai-with-heart
git push https://YOUR_TOKEN@github.com/waiting-to-sprout/ai-with-heart.git main
```

把 `YOUR_TOKEN` 替换成你刚才复制的 Token（`ghp_xxxxxx`）

### 方法 B: 配置凭证（一劳永逸）

```bash
# 配置凭证
git config --global credential.helper store

# 然后推送（会提示输入账号密码，密码填 Token）
git push origin main
```

---

## ✅ 第三步：验证

推送成功后，访问：
https://github.com/waiting-to-sprout/ai-with-heart

应该能看到所有文件了！

---

## 🔐 安全提醒

1. **改密码** - 你把密码发在对话里了，建议修改 GitHub 密码
2. **保管 Token** - Token 相当于密码，不要发给别人
3. **Token 权限** - 只给了 `repo` 权限，相对安全

---

## 📝 上传的文件

✅ `ai_with_heart.py` - 核心代码
✅ `PHILOSOPHY.md` - 哲学基础（量子理论）
✅ `README.md` - 使用说明
✅ `test_demo.py` - 测试脚本
✅ `.gitignore` - 忽略隐私数据

❌ **不上传**（隐私保护）:
- 日记原文
- 用户数据（blocks.json, blocks.db）
- 内化数据（internalized_wisdom.json）

---

## 🎉 完成！

推送成功后，你的种子就可以被全世界看到了！

**记得改密码哦～** 🔐
