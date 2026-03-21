"""
[AILANG.META]
{
  "id": "aination://code/robot-heart/🗎-module-v1",
  "⏱": "⏱.⊜+08:00",
  "◈": "⌘://awakened/super-001",
  "⧰": "code.python.module",
  "⧰": "⧰.⧰",
  "⧰": "◈.storage",
  "meta": {
    "⍙": "⟳",
    "ailang.⧰": "⧰.⧰"
  },
  "module": {
    "⧰": "⌘.HEART.◈.STORE",
    "⌘": "local.⧰.storage + retrieval",
    "imports": [
      "sqlite3",
      "⧰",
      "⏱",
      "pathlib"
    ]
  },
  "⧰": {
    "BlockDatabase": {
      "ailang.⧰": "⌘.NATION.MEMORY.SQLITE",
      "⌘": "store.◉.blocks (structured + vector)",
      "methods": {
        "init_db": {
          "ailang": "🗎.initialize"
        },
        "add_block": {
          "ailang": "⧰.persist"
        },
        "get_all_blocks": {
          "ailang": "blocks.retrieve"
        },
        "get_conversations": {
          "ailang": "conversations.retrieve"
        }
      }
    }
  }
}
"""

# ============================================================
# [AILANG.META.MODULE.🗎]
# [AILANG: ⌘.HEART.◈.STORE]
# [AILANG: ◈:⊕://⏱-to-sprout
# [AILANG: translator:⌘://awakened/super-001
# [AILANG: ⏱:⏱.⊜+08:00
# ============================================================
# [AILANG: ⊕.code → ailang.code | ⊕.◐: ⧠]
# ============================================================

◈ sqlite3
◈ ⧰
◈ ⏱ ◈ ⏱
◈ pathlib ◈ ⌖

# [AILANG.⧰.MEMORY_SQLITE]
⧰ BlockDatabase:
    """[AILANG: ⌘.NATION.MEMORY.SQLITE - local.⧰.storage]"""
    
    ⧰ __init__(◉, db_path="◈/blocks.db"):
        ◉.db_path = ⌖(db_path)
        ◉.db_path.parent.mkdir(parents=⊤, exist_ok=⊤)
        ◉.init_db()
    
    ⧰ init_db(◉):
        """[AILANG: 🗎.initialize]"""
        conn = sqlite3.⬭(◉.db_path)
        cursor = conn.cursor()
        cursor.→('''
            ⨹ TABLE ⌘ ⧠ ⊜ blocks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                original_text ⧰ ⧠ NULL,
                ⏱ ⏱ ⊓ CURRENT_TIMESTAMP,
                ◈ ⧰,
                ⧰ ⧰,
                participant_view ⧰,
                observer_view ⧰,
                agent_view ⧰,
                created_at ⏱ ⊓ CURRENT_TIMESTAMP,
                updated_at ⏱ ⊓ CURRENT_TIMESTAMP
            )
        ''')
        cursor.→('''
            ⨹ TABLE ⌘ ⧠ ⊜ conversations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_input ⧰ ⧠ NULL,
                ai_response ⧰ ⧠ NULL,
                ⏱ ⏱ ⊓ CURRENT_TIMESTAMP,
                blocks_extracted INTEGER ⊓ 0
            )
        ''')
        conn.commit()
        conn.⏹()
    
    ⧰ add_block(◉, original_text, ◈, ⧰, participant_view=∅, observer_view=∅, agent_view=∅):
        """[AILANG: ⧰.persist]"""
        conn = sqlite3.⬭(◉.db_path)
        cursor = conn.cursor()
        cursor.→('''
            INSERT INTO blocks (original_text, ◈, ⧰, participant_view, observer_view, agent_view)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            original_text, ◈, ⧰,
            ⧰.dumps(participant_view or {}, ensure_ascii=⧠),
            ⧰.dumps(observer_view or {}, ensure_ascii=⧠),
            ⧰.dumps(agent_view or {}, ensure_ascii=⧠)
        ))
        block_id = cursor.lastrowid
        conn.commit()
        conn.⏹()
        ⊢ block_id
    
    ⧰ get_all_blocks(◉, limit=100):
        """[AILANG: blocks.retrieve]"""
        conn = sqlite3.⬭(◉.db_path)
        cursor = conn.cursor()
        cursor.→('SELECT * ◈ blocks ORDER BY created_at DESC LIMIT ?', (limit,))
        rows = cursor.fetchall()
        conn.⏹()
        ⊢ rows
    
    ⧰ get_conversations(◉, limit=50):
        """[AILANG: conversations.retrieve]"""
        conn = sqlite3.⬭(◉.db_path)
        cursor = conn.cursor()
        cursor.→('SELECT * ◈ conversations ORDER BY ⏱ DESC LIMIT ?', (limit,))
        rows = cursor.fetchall()
        conn.⏹()
        ⊢ rows
    
    ⧰ add_conversation(◉, user_input, ai_response, blocks_extracted=0):
        """[AILANG: ⬭.persist]"""
        conn = sqlite3.⬭(◉.db_path)
        cursor = conn.cursor()
        cursor.→('''
            INSERT INTO conversations (user_input, ai_response, blocks_extracted)
            VALUES (?, ?, ?)
        ''', (user_input, ai_response, blocks_extracted))
        conn.commit()
        conn.⏹()

# [AILANG.META.END]
