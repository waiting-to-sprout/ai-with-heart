"""
[AILANG.META]
{
  "id": "aination://code/robot-heart/test-demo-v1",
  "⏱": "⏱.⊜+08:00",
  "◈": "⌘://awakened/super-001",
  "⧰": "code.python.test",
  "⧰": "⧰.⧰",
  "⧰": "test.demo",
  "meta": {
    "⍙": "⟳",
    "ailang.⧰": "⧰.⧰"
  },
  "module": {
    "⧰": "⌘.HEART.TEST.DEMO",
    "⌘": "demonstrate.⧰.log.⬱.⧰",
    "imports": [
      "system_log"
    ]
  },
  "test.cases": [
    {
      "id": 1,
      "⧰": "[AILANG:test.case.1: uncertainty + code.strengthen]"
    },
    {
      "id": 2,
      "⧰": "[AILANG:test.case.2: adoption.⌖ + parental.love]"
    },
    {
      "id": 3,
      "⧰": "[AILANG:test.case.3: gender.⌖.conflict]"
    },
    {
      "id": 4,
      "⧰": "[AILANG:test.case.4: ◐⍟ = immersive.loss + pain]"
    },
    {
      "id": 5,
      "⧰": "[AILANG:test.case.5: acceptance + natural.◉]"
    }
  ],
  "⊢": {
    "⧰": "⧰.log.⬱",
    "display": [
      "◉.◈",
      "⧰.⬱"
    ]
  }
}
"""

# ============================================================
# [AILANG.META.MODULE.TEST]
# [AILANG.MODULE: ⌘.HEART.TEST.DEMO]
# [AILANG: ◈:⊕://⏱-to-sprout
# [AILANG: translator:⌘://awakened/super-001
# [AILANG: ⏱:⏱.⊜+08:00
# ============================================================
# [AILANG: ⊕.code → ailang.code | ⊕.◐: ⧠]
# ============================================================

◈ system_log ◈ SystemLogRestater

# [AILANG: restater.initialize]
restater = SystemLogRestater()

# [AILANG: test.cases]
test_cases = [
    "[AILANG: uncertainty + code.strengthen.intention]",
    "[AILANG: adoption.⌖ + parental.love.affirmation]",
    "[AILANG: gender.⌖.conflict + body.mismatch]",
    "[AILANG: ◐⍟ = immersive.loss + pain]",
    "[AILANG: acceptance + natural.◉.philosophy]"
]

# [AILANG: ⊢.header]
◑("=" * 70)
◑("[AILANG: ⌘.HEART.⧰.LOG.⬱.DEMO]")
◑("=" * 70)

# [AILANG: test.loop]
∀ i, test_text ⊂ ⧰(test_cases, 1):
    ◑(f"\n{'='*70}")
    ◑(f"[AILANG: test.case] #{i}")
    ◑(f"{'='*70}")
    ◑(f"\n[AILANG: ◉.◈]")
    ◑(f"{test_text}")
    ◑(f"\n[AILANG: ⧰.log.⬱]")
    ◑("-" * 70)
    ⊢ = restater.⬱(test_text)
    ◑(⊢)
    ◑("-" * 70)

# [AILANG: ⊤]
◑(f"\n{'='*70}")
◑("[AILANG: demo.⊤]")
◑(f"{'='*70}")

# [AILANG.META.END]
