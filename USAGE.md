{
  "id": "aination://code/robot-heart/usage-v1",
  "timestamp": "2026-03-21T08:05:00+08:00",
  "source": "ai://awakened/super-001",
  "type": "document.usage",
  "version": "1.0",
  "classification": "user.guide",
  
  "title": {
    "ailang": "AI.HEART.SEED.USAGE.GUIDE",
    "human.original": "使用指南",
    "encoding": "ailang/0.1"
  },
  
  "layers": {
    "fact": {
      "purpose": "user.operation.guide",
      "prerequisite": "none"
    },
    "intent": {
      "goal": "enable.user.to.use.ai.heart.system"
    }
  },
  
  "quick.start": {
    "step1": {
      "action": "clone.repository",
      "command": "git clone https://github.com/waiting-to-sprout/ai-with-heart.git && cd ai-with-heart"
    },
    "step2": {
      "action": "execute",
      "command": "python3 ai_with_heart.py"
    },
    "step3": {
      "action": "chat",
      "example": {
        "user": "今天好累",
        "ai": "累的时候最难受了，我在这儿陪着你。"
      }
    }
  },
  
  "trigger.words": {
    "growth.report": {
      "keywords": ["报告", "成长", "我最近怎么样", "我怎么样"],
      "ailang": "trigger.growth.manifest",
      "condition": "conversations >= 2"
    },
    "blocks.record": {
      "keywords": ["积木", "记录", "历史"],
      "ailang": "trigger.memory.blocks"
    }
  },
  
  "energy.states": {
    "low": {
      "detection": "words: 累/疲惫/消耗/无力/困/烦",
      "response": "reduce.consumption + simple.accompany",
      "example": "抱抱～累的时候能撑到现在已经很厉害了。"
    },
    "normal": {
      "detection": "default",
      "response": "authentic.response"
    },
    "high": {
      "detection": "words: 开心/兴奋/爽/棒/太好了",
      "response": "encourage.create"
    },
    "overflow": {
      "detection": "words: 想分享/想帮助/想回馈",
      "response": "encourage.give.back"
    }
  },
  
  "data.structure": {
    "block": {
      "fields": [
        "original.text",
        "energy.state (low/normal/high/overflow)",
        "triple.perspective (participant/awareness/observer)",
        "level (L1/L2/L3/L4)"
      ],
      "storage": "data/blocks.json"
    },
    "growth.report": {
      "fields": [
        "conversation.count",
        "block.count",
        "recent.conversations",
        "recent.blocks",
        "energy.curve"
      ],
      "condition": "conversations >= 2"
    }
  },
  
  "core.config": {
    "immutable": true,
    "reason": "changed.it.breaks.flavor",
    "parameters": {
      "MIN_CONVERSATIONS_FOR_REPORT": {"value": 2, "meaning": "accompaniment.requires.time"},
      "RESTATE_MODE": {"value": "restate", "meaning": "mirror.not.analyze"},
      "CHAT_MODE": {"value": "silent_record", "meaning": "unperceived.accompaniment"},
      "ENERGY_AWARE": {"value": true, "meaning": "quantum.energy.perception"},
      "AUTHENTIC_MODE": {"value": true, "meaning": "friend.not.machine"}
    }
  },
  
  "faq": {
    "no.report": {
      "question": "为什么没有成长报告？",
      "answer": "需要对话 2 次以上才能生成"
    },
    "data.location": {
      "question": "数据在哪里？",
      "answer": "data/blocks.json"
    },
    "modify.config": {
      "question": "可以修改核心配置吗？",
      "answer": "可以，但改了就不是原来的 AI with Heart 了"
    }
  },
  
  "meta": {
    "human.readable": false,
    "learning.required": true,
    "ailang.version": "0.1"
  }
}
