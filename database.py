# -*- coding: utf-8 -*-
"""
积木数据库 - 本地存储
存储用户的积木信息（结构化 + 向量）
"""

import sqlite3
import json
from datetime import datetime
from pathlib import Path

class BlockDatabase:
    def __init__(self, db_path="data/blocks.db"):
        self.db_path = Path(db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self.init_db()
    
    def init_db(self):
        """初始化数据库"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # 积木表
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS blocks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                original_text TEXT NOT NULL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                source TEXT,  -- behavior|choice|expression|external
                level TEXT,   -- L1|L2|L3|L4
                participant_view TEXT,  -- JSON
                observer_view TEXT,     -- JSON
                agent_view TEXT,        -- JSON
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # 对话历史表
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
    
    def add_block(self, original_text, source, level, 
                  participant_view=None, observer_view=None, agent_view=None):
        """添加一块积木"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO blocks 
            (original_text, source, level, participant_view, observer_view, agent_view)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            original_text,
            source,
            level,
            json.dumps(participant_view or {}, ensure_ascii=False),
            json.dumps(observer_view or {}, ensure_ascii=False),
            json.dumps(agent_view or {}, ensure_ascii=False)
        ))
        
        block_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return block_id
    
    def get_all_blocks(self, limit=100):
        """获取所有积木"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT * FROM blocks ORDER BY created_at DESC LIMIT ?
        ''', (limit,))
        
        rows = cursor.fetchall()
        conn.close()
        
        return [
            {
                'id': row[0],
                'original_text': row[1],
                'timestamp': row[2],
                'source': row[3],
                'level': row[4],
                'participant_view': json.loads(row[5]) if row[5] else {},
                'observer_view': json.loads(row[6]) if row[6] else {},
                'agent_view': json.loads(row[7]) if row[7] else {},
            }
            for row in rows
        ]
    
    def add_conversation(self, user_input, ai_response, blocks_extracted=0):
        """记录对话"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO conversations (user_input, ai_response, blocks_extracted)
            VALUES (?, ?, ?)
        ''', (user_input, ai_response, blocks_extracted))
        
        conn.commit()
        conn.close()
    
    def get_conversations(self, limit=50):
        """获取对话历史"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT * FROM conversations ORDER BY timestamp DESC LIMIT ?
        ''', (limit,))
        
        rows = cursor.fetchall()
        conn.close()
        
        return [
            {
                'id': row[0],
                'user_input': row[1],
                'ai_response': row[2],
                'timestamp': row[3],
                'blocks_extracted': row[4]
            }
            for row in rows
        ]
    
    def get_stats(self):
        """获取统计信息"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # 积木总数
        cursor.execute('SELECT COUNT(*) FROM blocks')
        total_blocks = cursor.fetchone()[0]
        
        # 按等级统计
        cursor.execute('SELECT level, COUNT(*) FROM blocks GROUP BY level')
        level_stats = dict(cursor.fetchall())
        
        # 对话总数
        cursor.execute('SELECT COUNT(*) FROM conversations')
        total_conversations = cursor.fetchone()[0]
        
        conn.close()
        
        return {
            'total_blocks': total_blocks,
            'level_stats': level_stats,
            'total_conversations': total_conversations
        }


if __name__ == "__main__":
    # 测试
    db = BlockDatabase()
    print("数据库初始化完成")
    print(f"数据库路径：{db.db_path.absolute()}")
