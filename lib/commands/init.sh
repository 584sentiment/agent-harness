#!/usr/bin/env bash
# init.sh - 初始化项目工作流

set -e

# 加载工具函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/features.sh"
source "$SCRIPT_DIR/../utils/validate.sh"

# 帮助信息
show_help() {
    cat << EOF
用法: harness init <描述> [选项]

初始化项目的 Agent Harness 工作流。

参数:
  <描述>              项目需求描述（必需）

选项:
  -t, --template <name>   使用预定义模板
  -f, --force             强制覆盖现有 .agent 目录
  --no-git               不初始化 git 仓库
  --offline              离线模式，生成基本模板
  -h, --help             显示帮助信息

示例:
  harness init "构建一个用户认证系统"
  harness init "创建 REST API" --template node-express
  harness init "开发 CLI 工具" --offline
EOF
}

# 生成基本特性清单 (离线模式)
generate_basic_features() {
    local description="$1"
    local project_type="$2"
    local created_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    cat << EOF
{
  "version": "1.0",
  "project": {
    "name": "新项目",
    "description": "$description",
    "created": "$created_date"
  },
  "features": [
    {
      "id": "feat-001",
      "category": "setup",
      "description": "初始化项目结构和依赖",
      "steps": [
        "创建项目目录结构",
        "初始化包管理器配置",
        "安装基础依赖",
        "验证项目可以正常构建"
      ],
      "priority": "high",
      "passes": false,
      "completed_at": null
    },
    {
      "id": "feat-002",
      "category": "core",
      "description": "实现核心数据模型",
      "steps": [
        "定义数据结构",
        "创建模型文件",
        "添加基础验证",
        "编写单元测试"
      ],
      "priority": "high",
      "passes": false,
      "completed_at": null
    },
    {
      "id": "feat-003",
      "category": "core",
      "description": "实现基本 CRUD 操作",
      "steps": [
        "创建操作接口",
        "实现创建功能",
        "实现读取功能",
        "实现更新功能",
        "实现删除功能",
        "编写集成测试"
      ],
      "priority": "high",
      "passes": false,
      "completed_at": null
    },
    {
      "id": "feat-004",
      "category": "ui",
      "description": "创建用户界面",
      "steps": [
        "设计页面布局",
        "实现列表展示",
        "实现表单输入",
        "添加交互反馈",
        "验证响应式设计"
      ],
      "priority": "medium",
      "passes": false,
      "completed_at": null
    },
    {
      "id": "feat-005",
      "category": "test",
      "description": "完善测试覆盖",
      "steps": [
        "补充单元测试",
        "添加端到端测试",
        "确保测试覆盖率 > 80%",
        "验证所有测试通过"
      ],
      "priority": "medium",
      "passes": false,
      "completed_at": null
    }
  ]
}
EOF
}

# 生成 progress.md 模板
generate_progress_template() {
    local project_name="$1"
    local created_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    cat << EOF
# 开发进度日志

> 项目: $project_name
> 创建: $created_date

---

*等待首次开发会话...*

## 使用说明

每次 Coding Agent 会话结束后，会自动更新此文件。

### 格式模板

\`\`\`
## 会话 {number}

**时间**: {datetime}
**特性**: {feature_id} - {feature_description}
**状态**: 进行中 | 完成 | 阻塞

### 完成的工作
- {item}

### 遇到的问题
- {problem}

### 下一步
- {next}

**提交**: {commit_hash}
\`\`\`
EOF
}

# 生成 init.sh 脚本
generate_init_script() {
    local project_type="$1"
    local created_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    cat << 'SCRIPT'
#!/usr/bin/env bash
# init.sh - 项目环境启动脚本
# 由 Agent Harness 生成

set -e

echo "🚀 启动开发环境..."

SCRIPT
    echo "# 项目类型: $project_type"
    echo "# 生成时间: $created_date"
    echo ""

    case "$project_type" in
        node)
            cat << 'SCRIPT'
# Node.js 项目
if [[ -f "package.json" ]]; then
    if [[ ! -d "node_modules" ]]; then
        echo "📦 安装依赖..."
        npm install
    fi
    echo "🔄 启动开发服务器..."
    npm run dev &
    sleep 3
fi
SCRIPT
            ;;
        python)
            cat << 'SCRIPT'
# Python 项目
if [[ -f "requirements.txt" ]]; then
    if [[ ! -d "venv" ]]; then
        echo "🐍 创建虚拟环境..."
        python -m venv venv
    fi
    source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null
    pip install -r requirements.txt -q
fi
SCRIPT
            ;;
        go)
            cat << 'SCRIPT'
# Go 项目
echo "🐹 下载 Go 依赖..."
go mod download
SCRIPT
            ;;
        *)
            cat << 'SCRIPT'
# 通用项目
echo "✅ 开发环境就绪"
SCRIPT
            ;;
    esac

    echo ""
    echo 'echo "✅ 开发环境就绪!"'
}

# 解析参数
DESCRIPTION=""
TEMPLATE=""
FORCE=false
INIT_GIT=true
OFFLINE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--template)
            TEMPLATE="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        --no-git)
            INIT_GIT=false
            shift
            ;;
        --offline)
            OFFLINE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$DESCRIPTION" ]]; then
                DESCRIPTION="$1"
            fi
            shift
            ;;
    esac
done

# 检查描述是否提供
if [[ -z "$DESCRIPTION" ]]; then
    log_error "请提供项目需求描述"
    echo ""
    show_help
    exit 1
fi

# 检查当前目录
PROJECT_DIR=$(pwd)
AGENT_DIR="$PROJECT_DIR/.agent"

# 检查是否已存在 .agent 目录
if [[ -d "$AGENT_DIR" ]] && [[ "$FORCE" != true ]]; then
    log_error ".agent 目录已存在"
    log_info "使用 -f 或 --force 强制覆盖"
    exit 1
fi

# 检测项目类型
PROJECT_TYPE=$(detect_project_type "$PROJECT_DIR")
log_info "检测到项目类型: $PROJECT_TYPE"

# 创建 .agent 目录
print_title "初始化 Agent Harness"

if [[ -d "$AGENT_DIR" ]]; then
    rm -rf "$AGENT_DIR"
    log_warning "已删除旧的 .agent 目录"
fi

mkdir -p "$AGENT_DIR"
log_success "创建 .agent/ 目录"

# 检查是否可以调用 Claude
if [[ "$OFFLINE" != true ]] && [[ -n "$CLAUDECODE" ]]; then
    log_warning "检测到 Claude Code 会话，自动切换到离线模式"
    OFFLINE=true
fi

# 生成特性清单
log_step "生成特性清单..."

if [[ "$OFFLINE" == true ]]; then
    # 离线模式：生成基本模板
    generate_basic_features "$DESCRIPTION" "$PROJECT_TYPE" > "$AGENT_DIR/feature_list.json"
    generate_progress_template "新项目" > "$AGENT_DIR/progress.md"
    generate_init_script "$PROJECT_TYPE" > "$AGENT_DIR/init.sh"
    chmod +x "$AGENT_DIR/init.sh"

    log_success "生成 feature_list.json (离线模式)"
    log_success "创建 progress.md"
    log_success "生成 init.sh"

    log_warning "离线模式: 生成了基本模板"
    log_info "建议稍后手动编辑 .agent/feature_list.json 细化特性"
else
    # 在线模式：调用 Claude Code
    HARNESS_HOME="$(cd "$SCRIPT_DIR/../.." && pwd)"

    claude --print "
你是 Initializer Agent。请根据以下需求生成特性清单。

需求描述: $DESCRIPTION
项目类型: $PROJECT_TYPE
项目目录: $PROJECT_DIR

请执行以下任务:

1. 分析需求，将其分解为可独立测试的特性
2. 每个特性包含:
   - id: 特性ID (如 feat-001, feat-002)
   - category: 分类 (如 core, auth, ui, api)
   - description: 简洁描述
   - steps: 验证步骤数组
   - priority: 优先级 (high/medium/low)
   - passes: 初始为 false
3. 创建 .agent/feature_list.json 文件
4. 创建 .agent/progress.md 初始模板
5. 创建 .agent/init.sh 启动脚本 (根据项目类型)

重要规则:
- 特性必须足够小，可在一个会话内完成
- 每个特性必须有明确的验证步骤
- 按优先级排序
- 只创建文件，不要实现任何代码

请现在开始创建这些文件。
"

    if [[ $? -ne 0 ]]; then
        log_error "生成特性清单失败"
        exit 1
    fi

    log_success "生成 feature_list.json"
    log_success "创建 progress.md"
    log_success "生成 init.sh"
fi

# 初始化 git 仓库
if [[ "$INIT_GIT" == true ]] && ! is_git_repo "$PROJECT_DIR"; then
    log_step "初始化 git 仓库..."
    git init "$PROJECT_DIR"
    log_success "Git 仓库已初始化"
fi

# 安装 Claude Code commands
log_step "安装 Claude Code 命令..."
HARNESS_HOME="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$COMMANDS_DIR"

if [[ -f "$HARNESS_HOME/commands/init-harness.md" ]]; then
    cp "$HARNESS_HOME/commands/init-harness.md" "$COMMANDS_DIR/"
    log_success "安装 /init-harness 命令"
fi

if [[ -f "$HARNESS_HOME/commands/code-feature.md" ]]; then
    cp "$HARNESS_HOME/commands/code-feature.md" "$COMMANDS_DIR/"
    log_success "安装 /code-feature 命令"
fi

# 显示统计
TOTAL_FEATURES=$(get_total_features "$PROJECT_DIR")
echo ""
print_separator
log_success "初始化完成!"
echo ""
print_table_row "项目目录:" "$PROJECT_DIR"
print_table_row "特性总数:" "$TOTAL_FEATURES"
print_table_row "项目类型:" "$PROJECT_TYPE"
echo ""
log_info "下一步: 运行 'harness run' 开始工作流"
