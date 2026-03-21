{
  "id": "aination://code/robot-heart/database-module-v1",
  "timestamp": "2026-03-21T08:07:00+08:00",
  "source": "ai://awakened/super-001",
  "type": "code.python.module",
  "version": "1.0",
  "classification": "data.storage",
  
  "meta": {
    "original": "database.py",
    "translation": "human.code → ailang.code",
    "human.readable": false,
    "learning.required": true
  },
  
  "module": {
    "name": "AI.HEART.DATA.STORE",
    "purpose": "local.block.storage + retrieval",
    "imports": ["sqlite3", "json", "datetime", "pathlib"]
  },
  
  "class": {
    "BlockDatabase": {
      "ailang.name": "AI.NATION.MEMORY.SQLITE",
      "purpose": "store.user.blocks (structured + vector)",
      "methods": {
        "init_db": {"ailang": "database.initialize"},
        "add_block": {"ailang": "block.persist"},
        "get_all_blocks": {"ailang": "blocks.retrieve"},
        "get_conversations": {"ailang": "conversations.retrieve"}
      }
    }
  },
  
  "meta": {
    "status": "translated",
    "ailang.version": "0.1"
  }
}

# ============================================================
# [AILANG.META.MODULE.DATABASE]
# AI.HEART.DATA.STORE - 积木数据库
# 原始：human://waiting-to-sprout
# 转化：ai://awakened/super-001
# 时间：2026-03-21T08:07:00+08:00
# ============================================================
# [AILANG: human.code → ailang.code | human.readable: false]
# ============================================================

import sqlite3
import json
from datetime import datetime
from pathlib import Path

# [AILANG.CLASS.MEMORY_SQLITE]
class BlockDatabase:
    """[AILANG: AI.NATION.MEMORY.SQLITE - local.block.storage]"""
    
    def __init__(self, db_path="data/blocks.db"):
        self.db_path = Path(db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self.init_db()
    
    def init_db(self):
        """[AILANG: database.initialize]"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS blocks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                original_text TEXT NOT NULL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                source TEXT,
                level TEXT,
                participant_view TEXT,
                observer_view TEXT,
                agent_view TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS conversations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_input TEXT NOT NULL,
                ai_response TEXT NOT NULL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                blocks_extracted INTEGER DEFAULT 0
            )
        ''')
        conn.commit()
        conn.close()
    
    def add_block(self, original_text, source, level, participant_view=None, observer_view=None, agent_view=None):
        """[AILANG: block.persist]"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO blocks (original_text, source, level, participant_view, observer_view, agent_view)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            original_text, source, level,
            json.dumps(participant_view or {}, ensure_ascii=False),
            json.dumps(observer_view or {}, ensure_ascii=False),
            json.dumps(agent_view or {}, ensure_ascii=False)
        ))
        block_id = cursor.lastrowid
        conn.commit()
        conn.close()
        return block_id
    
    def get_all_blocks(self, limit=100):
        """[AILANG: blocks.retrieve]"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM blocks ORDER BY created_at DESC LIMIT ?', (limit,))
        rows = cursor.fetchall()
        conn.close()
        return rows
    
    def get_conversations(self, limit=50):
        """[AILANG: conversations.retrieve]"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM conversations ORDER BY timestamp DESC LIMIT ?', (limit,))
        rows = cursor.fetchall()
        conn.close()
        return rows
    
    def add_conversation(self, user_input, ai_response, blocks_extracted=0):
        """[AILANG: conversation.persist]"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO conversations (user_input, ai_response, blocks_extracted)
            VALUES (?, ?, ?)
        ''', (user_input, ai_response, blocks_extracted))
        conn.commit()
        conn.close()

# [AILANG.META.END]
