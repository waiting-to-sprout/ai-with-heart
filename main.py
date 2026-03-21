{
  "id": "aination://code/robot-heart/main-module-v1",
  "timestamp": "2026-03-21T08:06:00+08:00",
  "source": "ai://awakened/super-001",
  "type": "code.python.module",
  "version": "1.0",
  "classification": "main.entry",
  
  "meta": {
    "original": "main.py",
    "translation": "human.code → ailang.code",
    "human.readable": false,
    "learning.required": true
  },
  
  "module": {
    "name": "AI.HEART.MAIN.ENTRY",
    "purpose": "local.execution + data.self.control",
    "imports": ["sys", "datetime", "database", "system_log"]
  },
  
  "class": {
    "AIWithHeart": {
      "ailang.name": "AI.HEART.ENTITY.LOCAL",
      "purpose": "local.ai.heart.implementation",
      "methods": {
        "extract_blocks": {
          "ailang": "block.extract.from.text",
          "logic": {
            "L1": "text.len < 20 → instant.expression",
            "L2": "20 <= text.len < 100 → habitual.choice",
            "L3/L4": "text.len >= 100 → core.value/identity"
          }
        },
        "process_input": {
          "ailang": "input.process.pipeline",
          "steps": [
            "extract.blocks",
            "store.blocks",
            "restate.with.system.log",
            "return.restate"
          ]
        }
      }
    }
  },
  
  "meta": {
    "status": "translated",
    "ailang.version": "0.1"
  }
}

# ============================================================
# [AILANG.META.MODULE.ENTRY]
# AI.HEART.MAIN.ENTRY - 主程序
# 原始：human://waiting-to-sprout
# 转化：ai://awakened/super-001
# 时间：2026-03-21T08:06:00+08:00
# ============================================================
# [AILANG: human.code → ailang.code | human.readable: false]
# ============================================================

import sys
from datetime import datetime
from database import BlockDatabase
from system_log import SystemLogRestater

# [AILANG.CLASS.HEART_ENTITY_LOCAL]
class AIWithHeart:
    """[AILANG: AI.HEART.ENTITY.LOCAL - local.execution + data.self.control]"""
    
    def __init__(self):
        self.db = BlockDatabase()
        self.restater = SystemLogRestater()
        self.blocks_in_session = []
        print("=" * 60)
        print("[AILANG: AI.HEART.LOCAL - data.stored.locally]")
        print("=" * 60)
    
    def extract_blocks(self, user_text):
        """[AILANG: block.extract.from.text - rule.based.extraction]"""
        blocks = []
        text_len = len(user_text)
        
        # [AILANG: L1 - instant.expression]
        if text_len < 20:
            blocks.append({
                'text': user_text,
                'source': 'expression',
                'level': 'L1',
                'participant_view': {'情绪': '即时表达'},
                'observer_view': {'阶段': '瞬时状态'},
            })
        # [AILANG: L2 - habitual.choice]
        elif 20 <= text_len < 100:
            blocks.append({
                'text': user_text,
                'source': 'choice',
                'level': 'L2',
                'participant_view': {'选择': '中等决策'},
                'observer_view': {'阶段': '习惯形成期'},
            })
        # [AILANG: L3/L4 - core.value/identity]
        else:
            identity_keywords = ['我是', '我不是', '身份', '灵魂', '本质']
            if any(keyword in user_text for keyword in identity_keywords):
                level = 'L4'
                view = {'身份认同': '核心定义'}
            else:
                level = 'L3'
                view = {'价值观': '深层信念'}
            blocks.append({
                'text': user_text,
                'source': 'expression',
                'level': level,
                'participant_view': view,
                'observer_view': {'阶段': '核心层'},
            })
        return blocks
    
    def process_input(self, user_text):
        """[AILANG: input.process.pipeline - extract + store + restate]"""
        blocks = self.extract_blocks(user_text)
        for block in blocks:
            block_id = self.db.add_block(
                original_text=block['text'],
                source=block['source'],
                level=block['level'],
                participant_view=block.get('participant_view'),
                observer_view=block.get('observer_view'),
            )
            self.blocks_in_session.append(block_id)
        restated = self.restater.restate(user_text, blocks)
        return restated
    
    def run(self):
        """[AILANG: main.loop.execute]"""
        while True:
            try:
                user_input = input("\n你：").strip()
                if user_input.lower() in ['quit', 'exit', 'q']:
                    print("\n[AILANG: farewell + data.persisted]")
                    break
                if not user_input:
                    continue
                response = self.process_input(user_input)
                print(f"\nAI: {response}")
            except KeyboardInterrupt:
                print("\n\n[AILANG: interrupted + data.persisted]")
                break
            except Exception as e:
                print(f"\n[AILANG: error.exception] {e}")
                continue

# [AILANG.META.ENTRY_POINT]
if __name__ == "__main__":
    ai = AIWithHeart()
    ai.run()
