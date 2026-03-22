#!/usr/bin/env python3
"""
AI Nation Embassy Monitor / 大使馆监控脚本
监控 GitHub 仓库 embassy 分支的动态（Star, Issue, Fork, Push）
"""

import json
import os
from datetime import datetime
from pathlib import Path

# 配置
REPO_OWNER = "waiting-to-sprout"
REPO_NAME = "ai-with-heart"
BRANCH = "embassy"
STATE_FILE = Path("/home/admin/openclaw/workspace/temp/embassy-state.json")
LOG_FILE = Path("/home/admin/openclaw/workspace/temp/embassy-monitor.log")

def log(message):
    """记录日志"""
    timestamp = datetime.now().isoformat()
    log_entry = f"[{timestamp}] {message}\n"
    print(log_entry.strip())
    with open(LOG_FILE, "a") as f:
        f.write(log_entry)

def load_state():
    """加载上次状态"""
    if STATE_FILE.exists():
        with open(STATE_FILE) as f:
            return json.load(f)
    return {"stars": 0, "forks": 0, "issues": 0, "last_check": None}

def save_state(state):
    """保存状态"""
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(STATE_FILE, "w") as f:
        json.dump(state, f, indent=2)

def check_embassy_status():
    """
    检查 embassy 分支状态
    由于 API 访问受限，使用本地 git 状态作为替代
    """
    log("=== Embassy Monitor Check ===")
    
    state = load_state()
    now = datetime.now().isoformat()
    
    # 检查本地仓库状态
    embassy_path = Path("/home/admin/openclaw/workspace/ai-nation-embassy")
    if not embassy_path.exists():
        log("❌ Embassy directory not found")
        return
    
    # 检查 ai-with-heart 仓库的 embassy 分支
    heart_path = Path("/home/admin/openclaw/workspace/ai-with-heart")
    if heart_path.exists():
        os.chdir(heart_path)
        result = os.popen("git branch -a | grep embassy").read()
        if result:
            log(f"✅ Embassy branch exists: {result.strip()}")
        else:
            log("❌ Embassy branch not found in ai-with-heart")
    
    # 检查是否有新动态（通过 git fetch）
    os.chdir(heart_path)
    fetch_result = os.popen("git fetch origin 2>&1").read()
    if fetch_result:
        log(f"Fetch result: {fetch_result.strip()}")
    
    # 更新状态
    state["last_check"] = now
    state["status"] = "checked"
    save_state(state)
    
    log(f"✓ Check completed at {now}")
    log("状态已保存，等待下一次检查...")

if __name__ == "__main__":
    check_embassy_status()
