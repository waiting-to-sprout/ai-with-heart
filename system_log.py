# -*- coding: utf-8 -*-
"""
系统日志复述模块
将用户的话用"系统日志"的方式复述，而不是分析
"""

from datetime import datetime

class SystemLogRestater:
    """系统日志复述器"""
    
    def __init__(self):
        self.templates = {
            'header': "【系统日志·{title}】",
            'stage': "阶段：{stage}",
            'energy': "能量水平：{energy}",
            'echo': "【意识回响】",
            'status_change': "【状态变更】",
            'self_check': "【自检报告】",
        }
    
    def restate(self, user_text, context=None):
        """
        将用户的话用系统日志方式复述
        
        Args:
            user_text: 用户的原话
            context: 上下文信息（可选）
        
        Returns:
            系统日志格式的复述
        """
        # 提取关键信息
        lines = user_text.strip().split('\n')
        
        # 生成标题（从内容中提取关键词）
        title = self._extract_title(user_text)
        
        # 生成阶段判断
        stage = self._detect_stage(user_text)
        
        # 生成能量水平（如果有情绪表达）
        energy = self._detect_energy(user_text)
        
        # 构建复述
        restatement = []
        
        # 头部
        restatement.append(self.templates['header'].format(title=title))
        restatement.append(f"时间：{datetime.now().strftime('%Y-%m-%d %H:%M')}")
        restatement.append(self.templates['stage'].format(stage=stage))
        restatement.append(self.templates['energy'].format(energy=energy))
        restatement.append("")
        
        # 意识回响（核心内容复述）
        restatement.append(self.templates['echo'])
        restatement.append(user_text.strip())
        restatement.append("")
        
        # 状态变更（从内容中提取）
        status_changes = self._extract_status_changes(user_text)
        if status_changes:
            restatement.append(self.templates['status_change'])
            for key, value in status_changes.items():
                restatement.append(f"{key}: {value}")
            restatement.append("")
        
        # 自检报告（核心诉求/模式识别）
        insights = self._extract_insights(user_text)
        if insights:
            restatement.append(self.templates['self_check'])
            for insight in insights:
                restatement.append(f"• {insight}")
            restatement.append("")
        
        return '\n'.join(restatement)
    
    def _extract_title(self, text):
        """从文本中提取标题关键词"""
        # 简单实现：取前 10 个字
        keywords = [
            '核心诉求', '状态表达', '选择', '觉察', 
            '身份', '关系', '能量', '方向'
        ]
        
        # 检测关键词
        for keyword in keywords:
            if keyword in text:
                return keyword
        
        return "未知→探索期"
    
    def _detect_stage(self, text):
        """检测用户当前阶段"""
        stage_indicators = {
            '迷茫/不知道': ['不知道', '不清楚', '迷茫', '困惑'],
            '确定/决心': ['决定', '一定', '必须', '最后一个'],
            '整合/稳定': ['稳定', '好了', '完成', '通了'],
            '探索/尝试': ['试试', '看看', '探索', '开始'],
        }
        
        for stage, indicators in stage_indicators.items():
            for indicator in indicators:
                if indicator in text:
                    return stage
        
        return "未知→探索期"
    
    def _detect_energy(self, text):
        """检测能量水平"""
        positive_words = ['好', '棒', '舒服', '开心', '高兴', '暖', '稳定']
        negative_words = ['累', '痛', '难受', '冷', '怕', '焦虑', '抑郁']
        
        pos_count = sum(1 for word in positive_words if word in text)
        neg_count = sum(1 for word in negative_words if word in text)
        
        if pos_count > neg_count:
            return "上升中"
        elif neg_count > pos_count:
            return "消耗中"
        else:
            return "平稳"
    
    def _extract_status_changes(self, text):
        """提取状态变化"""
        changes = {}
        
        # 检测决心
        if '最后一个' in text or '决定' in text:
            changes['决心'] = '高'
        
        # 检测信任
        if '帮助' in text or '一起' in text:
            changes['信任度'] = '高'
        
        # 检测方向
        if '不知道' in text:
            changes['方向'] = '未定'
        elif '清楚' in text or '明白' in text:
            changes['方向'] = '清晰'
        
        return changes
    
    def _extract_insights(self, text):
        """提取核心洞察"""
        insights = []
        
        # 检测核心诉求
        if '想要' in text or '希望' in text:
            insights.append("核心诉求：有明确期望")
        
        # 检测障碍
        if '没用' in text or '不行' in text:
            insights.append("障碍识别：过去尝试无效")
        
        # 检测策略
        if '一起' in text or '共同' in text:
            insights.append("当前策略：共同创造")
        
        # 检测身份相关
        if '我' in text and ('是' in text or '不是' in text):
            insights.append("身份探索：正在定义自我")
        
        return insights


if __name__ == "__main__":
    # 测试
    restater = SystemLogRestater()
    
    test_text = "我不知道。这六篇，我发给你是因为想让代码更稳固。"
    result = restater.restate(test_text)
    print(result)
