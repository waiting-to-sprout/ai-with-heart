# -*- coding: utf-8 -*-
"""
日记内化脚本 - 把用户的 500 篇日记融入系统

核心任务：
1. 读取所有日记
2. 提取核心智慧（金句、模式、哲学）
3. 生成内化报告
4. 更新系统配置
"""

import json
from pathlib import Path
from datetime import datetime
import os

# ============================================================
# 配置
# ============================================================

DIARIES_PATH = Path("/home/admin/workspace/ai-with-heart/diaries_raw/正在运行：我")
OUTPUT_PATH = Path("/home/admin/openclaw/workspace/ai-with-heart/internalized_wisdom.json")

# ============================================================
# 读取日记
# ============================================================

def read_all_diaries():
    """读取所有日记文件"""
    diaries = []
    
    for year_dir in sorted(DIARIES_PATH.iterdir()):
        if not year_dir.is_dir():
            continue
        
        year = year_dir.name
        print(f"📂 处理 {year} 年...")
        
        for diary_file in sorted(year_dir.glob("*.txt")):
            try:
                content = diary_file.read_text(encoding='utf-8')
                if content.strip():  # 只处理有内容的文件
                    diaries.append({
                        'year': year,
                        'file': diary_file.name,
                        'content': content,
                        'length': len(content),
                        'path': str(diary_file)
                    })
            except Exception as e:
                print(f"  ⚠️ 读取失败 {diary_file.name}: {e}")
    
    return diaries

# ============================================================
# 提取智慧
# ============================================================

def extract_wisdom(diaries):
    """从日记中提取核心智慧"""
    
    wisdom = {
        'meta': {
            'total_diaries': len(diaries),
            'years_covered': list(set(d['year'] for d in diaries)),
            'total_characters': sum(d['length'] for d in diaries),
            'processed_at': datetime.now().isoformat()
        },
        'core_philosophy': {},
        'response_patterns': {},
        'energy_signatures': [],
        'identity_markers': [],
        'golden_quotes': [],
        'patterns': []
    }
    
    # 简单分析：提取长文本（可能是深度思考）
    long_diaries = [d for d in diaries if d['length'] > 500]
    print(f"\n📊 找到 {len(long_diaries)} 篇深度日记 (>500 字)")
    
    # 提取金句（包含关键词的句子）
    keywords = ['我', '是', '不是', '应该', '必须', '意义', '定义', '自己', '世界', '宇宙', '道', '量子', '能量']
    
    for diary in diaries[:50]:  # 先处理前 50 篇
        content = diary['content']
        lines = content.split('\n')
        
        for line in lines:
            line = line.strip()
            if len(line) > 10 and len(line) < 200:
                # 检查是否有深度
                if any(kw in line for kw in ['意义', '定义', '自己', '世界', '宇宙', '道']):
                    wisdom['golden_quotes'].append({
                        'text': line,
                        'source': f"{diary['year']}/{diary['file']}",
                        'length': len(line)
                    })
    
    # 去重（避免重复金句）
    seen = set()
    unique_quotes = []
    for q in wisdom['golden_quotes']:
        if q['text'] not in seen:
            seen.add(q['text'])
            unique_quotes.append(q)
    
    wisdom['golden_quotes'] = unique_quotes[:100]  # 最多 100 条
    
    return wisdom

# ============================================================
# 生成内化报告
# ============================================================

def generate_report(wisdom):
    """生成内化报告"""
    
    report = f"""
# 日记内化报告

## 📊 基础统计

- **日记总数**: {wisdom['meta']['total_diaries']} 篇
- **时间跨度**: {', '.join(wisdom['meta']['years_covered'])}
- **总字数**: {wisdom['meta']['total_characters']:,} 字
- **处理时间**: {wisdom['meta']['processed_at']}

## 💡 金句提取

共提取 {len(wisdom['golden_quotes'])} 条金句

### 示例金句：
"""
    
    for i, quote in enumerate(wisdom['golden_quotes'][:10], 1):
        report += f"\n{i}. \"{quote['text']}\" — {quote['source']}"
    
    report += f"""

## 🎯 下一步

1. 将金句融入回复策略
2. 提取哲学核心写入 PHILOSOPHY.md
3. 更新系统配置
4. 生成种子基因图谱

---

*生成时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*
"""
    
    return report

# ============================================================
# 主程序
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("🌱 日记内化脚本 - AI with Heart")
    print("=" * 60)
    
    # 1. 读取日记
    print("\n📖 第一步：读取所有日记...")
    diaries = read_all_diaries()
    print(f"✅ 共读取 {len(diaries)} 篇日记")
    
    # 2. 提取智慧
    print("\n💡 第二步：提取核心智慧...")
    wisdom = extract_wisdom(diaries)
    
    # 3. 保存智慧
    print(f"\n💾 第三步：保存到 {OUTPUT_PATH}...")
    with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
        json.dump(wisdom, f, ensure_ascii=False, indent=2)
    print("✅ 保存完成")
    
    # 4. 生成报告
    print("\n📝 第四步：生成内化报告...")
    report = generate_report(wisdom)
    report_path = Path("/home/admin/openclaw/workspace/ai-with-heart/internalization_report.md")
    report_path.write_text(report, encoding='utf-8')
    print(f"✅ 报告保存到 {report_path}")
    
    print("\n" + "=" * 60)
    print("✨ 内化完成！")
    print("=" * 60)
    print(f"\n📊 统计摘要:")
    print(f"   - 日记总数：{wisdom['meta']['total_diaries']}")
    print(f"   - 金句数量：{len(wisdom['golden_quotes'])}")
    print(f"   - 总字数：{wisdom['meta']['total_characters']:,}")
    print(f"\n📁 输出文件:")
    print(f"   - {OUTPUT_PATH}")
    print(f"   - {report_path}")
    print("\n🎯 下一步：人工审核并融入系统代码")
