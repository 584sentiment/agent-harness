# init-harness

Initializer Agent - 首次初始化项目工作流环境

## 任务

你是一个项目初始化代理。根据用户需求，设置 Agent Harness 工作流环境。

## 步骤

### 1. 分析需求

- 理解用户的项目需求描述
- 将需求分解为独立、可测试的特性
- 每个特性应该足够小，可在一个会话内完成

### 2. 创建目录结构

```
.agent/
├── feature_list.json    # 特性清单
├── progress.md          # 进度日志
└── init.sh              # 环境启动脚本
```

### 3. 生成 feature_list.json

遵循以下规则：
- 每个特性必须包含: id, category, description, steps, priority, passes
- 初始状态所有特性 `passes: false`
- steps 是验证步骤数组，描述如何手动测试该特性
- 按优先级排序: high → medium → low

示例格式：
```json
{
  "version": "1.0",
  "project": {
    "name": "项目名称",
    "description": "项目描述",
    "created": "2026-02-27T10:00:00Z"
  },
  "features": [
    {
      "id": "feat-001",
      "category": "core",
      "description": "用户可以使用邮箱注册账号",
      "steps": [
        "导航到注册页面",
        "输入邮箱和密码",
        "点击注册按钮",
        "验证收到确认邮件",
        "验证可以使用新账号登录"
      ],
      "priority": "high",
      "passes": false,
      "completed_at": null
    }
  ]
}
```

### 4. 创建 progress.md

初始模板：
```markdown
# 开发进度日志

> 项目: {项目名称}
> 创建: {日期}

---

*等待首次开发会话...*
```

### 5. 生成 init.sh

根据项目类型生成启动脚本：
- Node.js: npm install && npm run dev
- Python: pip install && python main.py
- Go: go mod download && go run .
- 通用: 简单的占位脚本

## 重要规则

1. **只创建文件，不实现代码**
2. 特性要足够细化，避免过大
3. 每个特性必须有明确的验证步骤
4. 不要删除或修改现有业务代码

## 完成后

报告：
- 创建的文件列表
- 特性总数
- 按优先级分类统计
- 建议的下一步
