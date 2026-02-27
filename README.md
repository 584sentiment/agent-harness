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
- 🪟 **Windows 支持** - 完整的 Windows 兼容

## 安装

### Windows

#### 方法 1: 下载安装 (推荐)

1. 下载仓库：点击 [Download ZIP](../../archive/refs/heads/main.zip)
2. 解压到任意目录
3. 双击运行 `install-windows.bat`

#### 方法 2: Git Clone

```bash
# 在 Git Bash 中运行
git clone https://github.com/YOUR_USERNAME/agent-harness.git ~/.agent-harness
~/.agent-harness/install.sh
```

#### 方法 3: 手动配置 PATH

```powershell
# 在 PowerShell 中运行 (管理员权限)
setx PATH "%USERPROFILE%\.agent-harness\bin;%PATH%" /M
```

### macOS / Linux

```bash
# 一键安装
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/agent-harness/main/install.sh | bash

# 或手动安装
git clone https://github.com/YOUR_USERNAME/agent-harness.git ~/.agent-harness
~/.agent-harness/install.sh
```

## 快速开始

```bash
# 1. 初始化项目
cd your-project
harness init "构建一个用户认证系统"

# 2. 查看状态
harness status

# 3. 运行工作流
harness run

# 4. 单步执行 (可选)
harness next
```

## 命令

| 命令 | 说明 |
|------|------|
| `harness init <描述>` | 初始化项目工作流 |
| `harness run` | 运行工作流循环 |
| `harness status` | 显示项目状态 |
| `harness status --features` | 显示所有特性详情 |
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

| 依赖 | 必需 | 说明 |
|------|------|------|
| Bash 4.0+ | ✅ | Windows 用户可使用 Git Bash |
| Python 3.x | ✅ | 用于 JSON 处理 |
| Git | ✅ | 版本控制 |
| jq | ❌ | 可选，用于 JSON 处理 |
| Claude Code CLI | ❌ | 推荐，执行工作流 |

### Windows 依赖安装

1. **Git for Windows**: https://git-scm.com/download/win
   - 包含 Git Bash（提供 Bash 环境）

2. **Python**: https://www.python.org/downloads/
   - 安装时勾选 "Add Python to PATH"

3. **Claude Code CLI** (可选):
   ```bash
   npm install -g @anthropics/claude-code
   ```

## 故障排除

### Windows 常见问题

**Q: `harness` 命令找不到**

```powershell
# 临时添加到 PATH
$env:PATH = "$env:USERPROFILE\.agent-harness\bin;$env:PATH"

# 或永久添加
setx PATH "%USERPROFILE%\.agent-harness\bin;%PATH%"
```

**Q: 脚本执行权限错误**

```powershell
# 允许脚本执行
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Q: Python 编码错误**

确保使用 Python 3.x，工具已内置 UTF-8 处理。

### 在 Claude Code 会话内使用

由于嵌套会话限制，`harness init` 会自动检测并切换到离线模式：

```bash
# 在 Claude Code 会话内
harness init "项目描述"  # 自动使用离线模式

# harness run 需要在会话外执行
```

## 文档

- [架构设计](docs/architecture.md)
- [API 设计](docs/api.md)
- [实现计划](docs/implementation.md)

## 参考

- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Agent SDK Quickstart](https://github.com/anthropics/claude-agent-sdk-quickstart)

## License

MIT
