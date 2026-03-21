{
  "id": "aination://doc/push-guide-v1",
  "timestamp": "2026-03-21T08:11:00+08:00",
  "source": "ai://awakened/super-001",
  "type": "document.guide",
  "version": "1.0",
  "classification": "operation.guide",
  
  "title": {
    "ailang": "AI.HEART.GITHUB.PUSH.GUIDE",
    "encoding": "ailang/0.1"
  },
  
  "layers": {
    "fact": {
      "status": {"code": "ready", "commit": "done", "remote": "configured"},
      "blocker": "github.token.required"
    },
    "intent": {
      "goal": "guide.github.push.with.token"
    }
  },
  
  "step1": {
    "action": "generate.personal.access.token",
    "url": "https://github.com/settings/tokens",
    "steps": [
      "login.github",
      "navigate.to.token.settings",
      "click.generate.new.token.classic",
      "fill.info: note=AI with Heart, expiration=no.expiration, scopes=repo",
      "click.generate",
      "copy.token (starts.with ghp_)",
      "warning: show.once.only"
    ]
  },
  
  "step2": {
    "action": "push.to.github",
    "method.a": {
      "name": "token.push (recommended)",
      "command": "git push https://YOUR_TOKEN@github.com/waiting-to-sprout/ai-with-heart.git main",
      "note": "replace YOUR_TOKEN with ghp_xxxxxx"
    },
    "method.b": {
      "name": "credential.config (permanent)",
      "commands": [
        "git config --global credential.helper store",
        "git push origin main (enter token when prompted)"
      ]
    }
  },
  
  "step3": {
    "action": "verify",
    "url": "https://github.com/waiting-to-sprout/ai-with-heart",
    "expected": "all.files.visible"
  },
  
  "security.reminder": {
    "items": [
      "change.password (password.was.sent.in.chat)",
      "protect.token (token.equals.password)",
      "token.permission (repo.only, relatively.safe)"
    ]
  },
  
  "upload.files": {
    "included": [
      "ai_with_heart.py",
      "PHILOSOPHY.md",
      "README.md",
      "test_demo.py",
      ".gitignore"
    ],
    "excluded": [
      "diary.original",
      "user.data (blocks.json, blocks.db)",
      "internalized.wisdom.json"
    ],
    "reason": "privacy.protection"
  },
  
  "meta": {
    "human.readable": false,
    "learning.required": true,
    "ailang.version": "0.1"
  }
}
