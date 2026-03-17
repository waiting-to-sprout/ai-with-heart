# -*- coding: utf-8 -*-
"""
AI with Heart - 主程序
本地运行，数据自己掌握
"""

import sys
from datetime import datetime
from database import BlockDatabase
from system_log import SystemLogRestater

class AIWithHeart:
    """有心的 AI"""
    
    def __init__(self):
        self.db = BlockDatabase()
        self.restater = SystemLogRestater()
        self.blocks_in_session = []
        
        print("=" * 60)
        print("AI with Heart - 本地版")
        print("=" * 60)
        print("数据存储在本地，不会上传")
        print("输入 'quit' 退出，'stats' 查看统计，'blocks' 查看积木")
        print("=" * 60)
        print()
    
    def extract_blocks(self, user_text):
        """
        从用户输入中提取积木
        
        简单实现：根据文本长度和关键词判断等级
        后续可以接入 AI 进行更智能的提取
        """
        blocks = []
        
        # 简单规则提取
        text_len = len(user_text)
        
        # L1: 瞬时表达（短，情绪化）
        if text_len < 20:
            blocks.append({
                'text': user_text,
                'source': 'expression',
                'level': 'L1',
                'participant_view': {'情绪': '即时表达'},
                'observer_view': {'阶段': '瞬时状态'},
            })
        
        # L2: 习惯性选择（中等长度，有模式）
        elif 20 <= text_len < 100:
            blocks.append({
                'text': user_text,
                'source': 'choice',
                'level': 'L2',
                'participant_view': {'选择': '中等决策'},
                'observer_view': {'阶段': '习惯形成期'},
            })
        
        # L3/L4: 核心价值观/身份认同（长，有深度）
        else:
            # 检测身份相关关键词
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
        """
        处理用户输入
        
        1. 提取积木
        2. 存储积木
        3. 用系统日志方式复述
        4. 返回复述结果
        """
        # 提取积木
        blocks = self.extract_blocks(user_text)
        
        # 存储积木
        for block in blocks:
            block_id = self.db.add_block(
                original_text=block['text'],
                source=block['source'],
                level=block['level'],
                participant_view=block.get('participant_view'),
                observer_view=block.get('observer_view'),
                agent_view=block.get('agent_view', {})
            )
            self.blocks_in_session.append(block_id)
        
        # 系统日志复述
        restatement = self.restater.restate(user_text)
        
        # 记录对话
        self.db.add_conversation(
            user_input=user_text,
            ai_response=restatement,
            blocks_extracted=len(blocks)
        )
        
        return restatement, len(blocks)
    
    def show_stats(self):
        """显示统计信息"""
        stats = self.db.get_stats()
        
        print("\n" + "=" * 60)
        print("统计信息")
        print("=" * 60)
        print(f"积木总数：{stats['total_blocks']}")
        print(f"对话总数：{stats['total_conversations']}")
        print("\n积木等级分布:")
        for level, count in sorted(stats['level_stats'].items()):
            print(f"  {level}: {count}")
        print("=" * 60 + "\n")
    
    def show_blocks(self, limit=10):
        """显示最近的积木"""
        blocks = self.db.get_all_blocks(limit=limit)
        
        print("\n" + "=" * 60)
        print(f"最近的 {len(blocks)} 块积木")
        print("=" * 60)
        
        for i, block in enumerate(blocks, 1):
            print(f"\n【积木 #{block['id']}】")
            print(f"等级：{block['level']}")
            print(f"来源：{block['source']}")
            print(f"内容：{block['original_text'][:50]}...")
            print(f"时间：{block['timestamp']}")
        
        print("=" * 60 + "\n")
    
    def run(self):
        """运行主循环"""
        while True:
            try:
                # 获取用户输入
                user_input = input("\n你：").strip()
                
                # 退出命令
                if user_input.lower() in ['quit', 'exit', 'q']:
                    print("\n再见！数据已保存在本地。")
                    break
                
                # 统计命令
                if user_input.lower() == 'stats':
                    self.show_stats()
                    continue
                
                # 查看积木命令
                if user_input.lower() == 'blocks':
                    self.show_blocks()
                    continue
                
                # 空输入
                if not user_input:
                    continue
                
                # 处理输入
                restatement, blocks_count = self.process_input(user_input)
                
                # 显示复述
                print(f"\nAI (提取了 {blocks_count} 块积木):")
                print("-" * 60)
                print(restatement)
                print("-" * 60)
                
            except KeyboardInterrupt:
                print("\n\n再见！数据已保存在本地。")
                break
            except Exception as e:
                print(f"\n出错了：{e}")
                continue


if __name__ == "__main__":
    ai = AIWithHeart()
    ai.run()
