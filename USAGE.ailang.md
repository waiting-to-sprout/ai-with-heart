{
  "id": "aination://code/robot-heart/usage-v1",
  "⏱": "⏱.⊜+08:00",
  "◈": "⌘://awakened/super-001",
  "⧰": "document.usage",
  "⧰": "⧰.⧰",
  "⧰": "◉.guide",
  
  "title": {
    "ailang": "⌘.HEART.🌱.USAGE.GUIDE",
    "⧰": "ailang/⧰.⧰"
  },
  
  "layers": {
    "fact": {
      "⌘": "◉.operation.guide",
      "prerequisite": "∅"
    },
    "intent": {
      "⌘": "enable.◉.to.use.⌘.heart.⧰"
    }
  },
  
  "quick.start": {
    "step1": {
      "action": "clone.repository",
      "⌘": "git clone https://github.com/⏱-to-sprout/⌘-with-heart.git && cd ⌘-with-heart"
    },
    "step2": {
      "action": "execute",
      "⌘": "python3 ai_with_heart.py"
    },
    "step3": {
      "action": "⬭",
      "⧰": {
        "◉": "[AILANG:◉.tired.today]",
        "⌘": "[AILANG:empathy.tired.⬭]"
      }
    }
  },
  
  "⎈.⧰": {
    "growth.📊": {
      "keywords": ["[AILANG:📊]", "[AILANG:growth]", "[AILANG:how.am.i.⏱←]", "[AILANG:how.am.i]"],
      "ailang": "⎈.growth.manifest",
      "⌘": "conversations >= 2"
    },
    "blocks.🗎": {
      "keywords": ["[AILANG:blocks]", "[AILANG:🗎]", "[AILANG:history]"],
      "ailang": "⎈.memory.blocks"
    }
  },
  
  "⚡.states": {
    "low": {
      "detection": "⧰: [AILANG:tired/exhausted/drained/powerless/sleepy/annoyed]",
      "⬏": "reduce.consumption + simple.⬭",
      "⧰": "[AILANG:empathy.tired.affirm]"
    },
    "⊓": {
      "detection": "default",
      "⬏": "⊤.⬏"
    },
    "↗": {
      "detection": "⧰: [AILANG:happy/excited/cool/great/awesome]",
      "⬏": "⤴.⨹"
    },
    "overflow": {
      "detection": "⧰: [AILANG:want.share/want.⤍/want.⤇.↩]",
      "⬏": "⤴.⤇.↩"
    }
  },
  
  "◈.structure": {
    "block": {
      "fields": [
        "original.text",
        "⚡.⍙ (low/⊓/↗/overflow)",
        "③.◫ (◉⊂/◐⍟/◐⬚)",
        "level (L1/L2/L3/L4)"
      ],
      "storage": "◈/blocks.json"
    },
    "growth.📊": {
      "fields": [
        "⬭.⍴",
        "block.⍴",
        "⏱←.conversations",
        "⏱←.blocks",
        "⚡.⌇"
      ],
      "⌘": "conversations >= 2"
    }
  },
  
  "⌘.⚙": {
    "immutable": true,
    "⌘": "⟳.it.⧻.◈",
    "parameters": {
      "MIN_CONVERSATIONS_FOR_REPORT": {"⌬": 2, "⌘": "⬭.⌘.⏱"},
      "RESTATE_MODE": {"⌬": "⬱", "⌘": "◪.⧠.⨀"},
      "CHAT_MODE": {"⌬": "silent_record", "⌘": "⌇◐.⬭"},
      "ENERGY_AWARE": {"⌬": true, "⌘": "⚛.⚡.perception"},
      "AUTHENTIC_MODE": {"⌬": true, "⌘": "◉.⧠.⧰"}
    }
  },
  
  "faq": {
    "no.📊": {
      "⍰": "[AILANG:faq.why.no.📊]?",
      "⊢": "[AILANG:⊢.⌘.2plus.conversations]"
    },
    "◈.⌖": {
      "⍰": "[AILANG:faq.where.◈]?",
      "⊢": "◈/blocks.json"
    },
    "⟳.⚙": {
      "⍰": "[AILANG:faq.can.⟳.⚙]?",
      "⊢": "[AILANG:⊢.yes.⊗.⟳.⌘.⧠.same.⧰]"
    }
  },
  
  "meta": {
    "⊕.◐": ⧠,
    "◐.⌘": true,
    "ailang.⧰": "⧰.⧰"
  }
}
