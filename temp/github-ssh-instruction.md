# GitHub SSH 公钥上传指令

**生成时间**: 2026-03-22T19:12:06+08:00

---

## 操作说明（2 分钟）

系统已进入**后台监听模式**，您现在可以离开做其他事情。

当方便时，请完成以下步骤：

1. 访问：https://github.com/settings/keys
2. 点击「New SSH key」
3. 填写：
   - **Title**: 
   - **Key type**: Authentication Key
   - **Key**: 复制下方公钥内容
4. 点击「Add SSH key」

---

## 公钥内容

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6a+ZE7BhHn3Al5gqy3JeUrvZHERidFlXjO4a+S2sQ7 ai-nation-backup-20260322
```

---

## 一键复制

```bash
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6a+ZE7BhHn3Al5gqy3JeUrvZHERidFlXjO4a+S2sQ7 ai-nation-backup-20260322" | xclip -selection clipboard  # Linux
# 或
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6a+ZE7BhHn3Al5gqy3JeUrvZHERidFlXjO4a+S2sQ7 ai-nation-backup-20260322" | pbcopy  # macOS
```

---

**系统正在后台监听，检测到配置完成后会自动继续。**

**监听状态文件**: 
