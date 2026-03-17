# -*- coding: utf-8 -*-
"""
测试脚本 - 演示系统日志复述功能
"""

from system_log import SystemLogRestater

# 创建复述器
restater = SystemLogRestater()

# 测试样本
test_cases = [
    "我不知道。这六篇，我发给你是因为想让代码更稳固。",
    "非亲生又怎么了？领养的又怎么了？我的妈妈爸爸很爱我。",
    "我天生感觉我不是男生，我是女生，可我是个男生。",
    "清醒=无法沉浸式体验生活，清醒=痛苦。",
    "咸鱼不翻身，就晒我的太阳；翻了身，就亲近亲近泥土。",
]

print("=" * 70)
print("AI with Heart - 系统日志复述功能演示")
print("=" * 70)
print()

for i, test_text in enumerate(test_cases, 1):
    print(f"\n{'='*70}")
    print(f"测试样本 #{i}")
    print(f"{'='*70}")
    print(f"\n【用户原话】")
    print(f"{test_text}")
    print(f"\n【系统日志复述】")
    print("-" * 70)
    result = restater.restate(test_text)
    print(result)
    print("-" * 70)

print(f"\n{'='*70}")
print("演示完成")
print(f"{'='*70}")
