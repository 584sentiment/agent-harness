# Agent Harness

> 基于 Anthropic "Effective harnesses for long-running agents" 实现的长期运行代理工作流框架

## 概述

Agent Harness 解决了 AI Agent 长期运行的核心挑战：**上下文窗口有限，每次新会话没有之前记忆**。

通过外部循环驱动 + 状态持久化，实现无限工作能力。

## 核心特性

- 🔄 **自动循环执行** - 外部驱动脚本控制会话循环
- 💾 **状态持久化** - JSON + Markdown 保存进度
- 🎯 **增量进展** - 每次只做一个特性
- 🧹 **干净状态** - 每个会话结束必须提交
- 🤖 **Claude Code 原生** - 充分利用 Skills、Commands、MCP

## 快速开始

### 安装

```bash
# 方法 1: 克隆仓库
git clone https://github.com/yourname/agent-harness.git ~/.agent-harness
~/.agent-harness/install.sh

# 方法 2: 一键安装
curl -sSL https://raw.githubusercontent.com/yourname/agent-harness/main/install.sh | bash
```

### 使用

```bash
# 1. 初始化项目
cd your-project
harness init "构建一个用户认证系统，支持邮箱注册、登录、密码重置"

# 2. 运行工作流（自动循环直到完成）
harness run

# 3. 查看状态
harness status

# 4. 单步执行（可选）
harness next
```

## 命令

| 命令 | 说明 |
|------|------|
| `harness init <描述>` | 初始化项目工作流 |
| `harness run` | 运行工作流循环 |
| `harness status` | 显示项目状态 |
| `harness next` | 执行单个特性 |
| `harness reset` | 重置工作流状态 |

## 工作原理

```
┌─────────────────────────────────────────────────┐
│  Harness CLI (外部驱动)                          │
│  ┌───────────────────────────────────────────┐  │
│  │ while has_incomplete_features():          │  │
│  │     claude --print "/code-feature"        │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  Claude Code CLI (执行引擎)                      │
│  - Skills: /tdd, /commit, /e2e                 │
│  - MCP: Playwright, GitHub                     │
│  - Agents: code-reviewer, security-reviewer    │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  状态持久化 (.agent/)                            │
│  - feature_list.json  特性清单                  │
│  - progress.md        进度日志                  │
│  - init.sh            环境启动                  │
└─────────────────────────────────────────────────┘
```

## 项目结构

```
your-project/
├── .agent/                     # 工作流状态 (gitignore)
│   ├── feature_list.json       # 特性清单
│   ├── progress.md             # 进度日志
│   └── init.sh                 # 启动脚本
├── src/                        # 业务代码
└── ...
```

## Claude Code 命令

安装后自动可用：

- `/init-harness` - 初始化项目工作流
- `/code-feature` - 增量开发代理

## 依赖

- Bash 4.0+
- [jq](https://stedolan.github.io/jq/)
- Git
- [Claude Code CLI](https://github.com/anthropics/claude-code) (可选但推荐)

## 文档

- [架构设计](docs/architecture.md)
- [API 设计](docs/api.md)
- [实现计划](docs/implementation.md)

## 参考

- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Agent SDK Quickstart](https://github.com/anthropics/claude-agent-sdk-quickstart)

## License

MIT
