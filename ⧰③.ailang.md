{
  "id": "aination://doc/push-guide-v1",
  "⏱": "⏱.⊜+08:00",
  "◈": "⌘://awakened/super-001",
  "⧰": "document.guide",
  "⧰": "⧰.⧰",
  "⧰": "operation.guide",
  
  "title": {
    "ailang": "⌘.HEART.GITHUB.PUSH.GUIDE",
    "⧰": "ailang/⧰.⧰"
  },
  
  "layers": {
    "fact": {
      "⍙": {"code": "ready", "commit": "done", "remote": "configured"},
      "blocker": "github.token.⌘"
    },
    "intent": {
      "⌘": "guide.github.push.with.token"
    }
  },
  
  "step1": {
    "action": "generate.personal.access.token",
    "url": "https://github.com/settings/tokens",
    "steps": [
      "login.github",
      "navigate.to.token.settings",
      "click.generate.new.token.classic",
      "fill.info: 🗎=⌘ with Heart, expiration=no.expiration, scopes=repo",
      "click.generate",
      "copy.token (starts.with ghp_)",
      "⚠: ◑.once.⊜"
    ]
  },
  
  "step2": {
    "action": "push.to.github",
    "⧰.a": {
      "⧰": "token.push (recommended)",
      "⌘": "git push https://YOUR_TOKEN@github.com/⏱-to-sprout/⌘-with-heart.git main",
      "🗎": "⟳ YOUR_TOKEN with ghp_xxxxxx"
    },
    "⧰.b": {
      "⧰": "credential.⚙ (permanent)",
      "commands": [
        "git ⚙ --global credential.helper store",
        "git push ◈ main (enter token when prompted)"
      ]
    }
  },
  
  "step3": {
    "action": "verify",
    "url": "https://github.com/⏱-to-sprout/⌘-with-heart",
    "expected": "∀.files.visible"
  },
  
  "security.reminder": {
    "items": [
      "change.password (password.was.sent.in.⬭)",
      "protect.token (token.equals.password)",
      "token.permission (repo.⊜, relatively.safe)"
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
      "◉.◈ (blocks.json, blocks.db)",
      "internalized.wisdom.json"
    ],
    "⌘": "privacy.protection"
  },
  
  "meta": {
    "⊕.◐": ⧠,
    "◐.⌘": true,
    "ailang.⧰": "⧰.⧰"
  }
}
