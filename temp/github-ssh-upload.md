# GitHub SSH 公钥上传

**时间**: 2026-03-22T18:57:27+08:00

---

## 操作步骤（2 分钟）

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

## 一键复制命令

```bash
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6a+ZE7BhHn3Al5gqy3JeUrvZHERidFlXjO4a+S2sQ7 ai-nation-backup-20260322" | xclip -selection clipboard
# 或
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6a+ZE7BhHn3Al5gqy3JeUrvZHERidFlXjO4a+S2sQ7 ai-nation-backup-20260322" | pbcopy  # macOS
```

---

**完成后运行**：
```bash
/home/admin/openclaw/workspace/scripts/setup-ssh-bridge.sh --verify
```
