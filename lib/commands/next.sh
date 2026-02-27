#!/usr/bin/env bash
# next.sh - 执行单个特性

set -e

# 加载工具函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/features.sh"
source "$SCRIPT_DIR/../utils/validate.sh"

# 帮助信息
show_help() {
    cat << EOF
用法: harness next [选项]

执行单个特性（单步模式）。

选项:
  -f, --feature <id>   指定特性 ID
  --skip-test         跳过测试验证
  -h, --help          显示帮助信息

示例:
  harness next
  harness next --feature auth-001
EOF
}

# 解析参数
FEATURE_ID=""
SKIP_TEST=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--feature)
            FEATURE_ID="$2"
            shift 2
            ;;
        --skip-test)
            SKIP_TEST=true
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
            shift
            ;;
    esac
done

# 检查项目目录
PROJECT_DIR=$(pwd)

if ! validate_agent_dir "$PROJECT_DIR"; then
    log_error "当前目录不是有效的 Agent Harness 项目"
    log_info "请先运行 'harness init <描述>' 初始化项目"
    exit 3
fi

# 获取下一个特性
if [[ -z "$FEATURE_ID" ]]; then
    FEATURE_ID=$(get_next_feature "$PROJECT_DIR")
fi

if [[ -z "$FEATURE_ID" ]]; then
    log_success "所有特性已完成!"
    exit 4
fi

FEATURE_DESC=$(get_feature_description "$PROJECT_DIR" "$FEATURE_ID")

print_title "单步执行"

echo "特性: $FEATURE_ID"
echo "描述: $FEATURE_DESC"
echo ""

# 调用 Claude Code
log_step "开始执行..."

if [[ "$SKIP_TEST" == true ]]; then
    claude --print "
执行 Coding Agent 单步模式。

当前特性: $FEATURE_ID
描述: $FEATURE_DESC
项目目录: $PROJECT_DIR

请按以下步骤工作:
1. 读取 .agent/progress.md 和 .agent/feature_list.json
2. 实现 $FEATURE_ID 特性
3. 跳过测试验证（用户指定）
4. 更新状态并提交

完成后标记该特性为完成。
"
else
    claude "/code-feature"
fi

# 显示结果
COMPLETED=$(get_completed_features "$PROJECT_DIR")
TOTAL=$(get_total_features "$PROJECT_DIR")

echo ""
log_success "执行完成"
log_info "进度: $COMPLETED/$TOTAL"
