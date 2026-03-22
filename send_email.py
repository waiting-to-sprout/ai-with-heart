# -*- coding: utf-8 -*-
"""
发送邮件脚本
"""

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from pathlib import Path

# 配置
from_addr = "no-reply@openclaw.local"  # 本地发送
to_addr = "3188549670@qq.com"
subject = "AI with Heart - 本地版代码"
body = """
你好！

这是「AI with Heart - 本地版」的代码包。

【使用方法】
1. 解压 ai-with-heart.zip
2. 打开终端/命令行
3. 进入 ai-with-heart 文件夹
4. 运行：python3 main.py
5. 开始对话

【说明】
- 所有数据存储在本地，不会上传
- 输入 'quit' 退出
- 输入 'stats' 查看统计
- 输入 'blocks' 查看积木

有任何问题，随时回来找我。

祝好！
AI with Heart
"""

# 附件路径
zip_path = Path("/home/admin/openclaw/workspace/ai-with-heart.zip")

if not zip_path.exists():
    print(f"错误：文件不存在 {zip_path}")
    exit(1)

# 创建邮件
msg = MIMEMultipart()
msg['From'] = from_addr
msg['To'] = to_addr
msg['Subject'] = subject

# 添加正文
msg.attach(MIMEText(body, 'plain', 'utf-8'))

# 添加附件
with open(zip_path, 'rb') as f:
    part = MIMEBase('application', 'octet-stream')
    part.set_payload(f.read())
    encoders.encode_base64(part)
    part.add_header(
        'Content-Disposition',
        f'attachment; filename="ai-with-heart.zip"'
    )
    msg.attach(part)

# 尝试发送
# 注意：这需要 SMTP 服务器配置
# 如果本地没有 SMTP 服务器，这段代码会失败

try:
    # 尝试本地 SMTP
    server = smtplib.SMTP('localhost', 25)
    server.sendmail(from_addr, to_addr, msg.as_string())
    server.quit()
    print("✅ 邮件已发送")
except Exception as e:
    print(f"❌ 发送失败：{e}")
    print("\n由于本地没有配置 SMTP 服务器，无法直接发送邮件。")
    print("请手动从以下路径获取文件：")
    print(f"  {zip_path.absolute()}")
    print("\n或者使用其他文件传输方式。")
