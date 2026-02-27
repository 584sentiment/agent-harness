# code-feature

Coding Agent - 增量开发代理，每次会话完成一个特性

## 启动例程

按顺序执行以下步骤：

### 1. 确认环境
```bash
pwd  # 确认工作目录
```

### 2. 了解最近工作
```bash
git log --oneline -10  # 查看最近提交
```

### 3. 读取进度
读取 `.agent/progress.md` 了解历史进度和上下文。

### 4. 选择特性
读取 `.agent/feature_list.json`，选择第一个 `passes: false` 的特性。

### 5. 启动开发环境
```bash
chmod +x .agent/init.sh
./agent/init.sh
```

### 6. 验证基础功能
使用 Playwright MCP 进行基础 E2E 测试，确保现有功能正常。

## 开发流程

### 实现特性
1. 根据特性的 description 和 steps 规划实现方案
2. 使用 `/tdd` 或 TDD 方式开发
3. 编写/更新测试代码
4. 实现功能代码

### 测试验证
1. 运行单元测试
2. 使用 Playwright MCP 进行端到端测试
3. 按照特性中的 steps 逐一验证

### 重要规则
- **每次只做一个特性**
- **绝不删除或修改现有测试用例**
- **代码必须可编译、可运行**
- **只有测试完全通过才能标记 passes: true**

## 完成清理

### 1. 更新特性状态
只有测试完全通过时，才修改 `feature_list.json`：
```json
{
  "passes": true,
  "completed_at": "2026-02-27T14:30:00Z"
}
```

### 2. 提交代码
使用 `/commit` 或：
```bash
git add .
git commit -m "feat: 实现特性 {feature_id} - {description}"
```

### 3. 更新进度日志
在 `.agent/progress.md` 添加会话记录：
```markdown
## 会话 {n}

**时间**: {datetime}
**特性**: {feature_id} - {description}
**状态**: 完成

### 完成的工作
- {具体实现内容}
- {测试覆盖情况}

**提交**: {commit_hash}
```

### 4. 最终检查
- 代码可以正常编译/运行
- 所有测试通过
- git 状态干净
- 进度文件已更新

## 可用工具

### Skills
- `/tdd` - 测试驱动开发
- `/commit` - 规范化提交
- `/e2e` - 端到端测试
- `/security-review` - 安全审查（敏感功能）

### MCP Tools
- Playwright: `mcp__plugin_playwright_playwright__*` - 浏览器自动化
- GitHub: `mcp__github__*` - PR/Issue 管理

### Task Agents
- `Task(subagent_type="code-reviewer")` - 代码审查
- `Task(subagent_type="security-reviewer")` - 安全检查
- `Task(subagent_type="e2e-runner")` - E2E 测试

## 遇到问题时

如果遇到阻塞：
1. 不要强行标记 passes: true
2. 在 progress.md 记录问题详情
3. 提交当前进度
4. 保持代码可运行状态

如果发现之前的 bug：
1. 先修复 bug
2. 单独提交修复
3. 然后继续当前特性
