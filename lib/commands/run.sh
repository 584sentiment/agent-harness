#!/usr/bin/env bash
# run.sh - 运行工作流循环

set -e

# 加载工具函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/features.sh"
source "$SCRIPT_DIR/../utils/validate.sh"

# 帮助信息
show_help() {
    cat << EOF
用法: harness run [选项]

启动工作流循环，自动执行直到所有特性完成。

选项:
  -m, --model <model>      指定 Claude 模型 (sonnet/opus/haiku)
  --max-sessions <n>       最大会话数限制
  --dry-run               只显示将执行的操作
  -v, --verbose           详细输出
  -h, --help              显示帮助信息

示例:
  harness run
  harness run --model opus
  harness run --max-sessions 10
  harness run --dry-run
EOF
}

# 解析参数
MODEL="sonnet"
MAX_SESSIONS=0
DRY_RUN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        --max-sessions)
            MAX_SESSIONS="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
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

# 获取项目信息
PROJECT_NAME=$(get_project_name "$PROJECT_DIR")
TOTAL=$(get_total_features "$PROJECT_DIR")
COMPLETED=$(get_completed_features "$PROJECT_DIR")
INCOMPLETE=$(get_incomplete_features "$PROJECT_DIR")

# 显示初始状态
print_title "工作流启动"

echo "项目: $PROJECT_NAME"
echo "目录: $PROJECT_DIR"
echo ""
echo "进度统计:"
echo "  ✓ 已完成: $COMPLETED/$TOTAL"
echo "  ✗ 待处理: $INCOMPLETE"
echo ""

if [[ "$INCOMPLETE" -eq 0 ]]; then
    log_success "所有特性已完成!"
    exit 4
fi

# Dry run 模式
if [[ "$DRY_RUN" == true ]]; then
    log_info "Dry run 模式 - 将执行以下操作:"
    echo ""
    list_incomplete_features "$PROJECT_DIR" | while IFS='|' read -r id desc; do
        echo "  - $id: $(echo "$desc" | xargs)"
    done
    echo ""
    log_info "将执行 $INCOMPLETE 个会话"
    exit 0
fi

# 开始循环
SESSION_COUNT=0
START_TIME=$(date +%s)

while has_incomplete_features "$PROJECT_DIR"; do
    # 检查会话限制
    if [[ "$MAX_SESSIONS" -gt 0 ]] && [[ "$SESSION_COUNT" -ge "$MAX_SESSIONS" ]]; then
        log_warning "已达到最大会话数限制 ($MAX_SESSIONS)"
        break
    fi

    SESSION_COUNT=$((SESSION_COUNT + 1))
    NEXT_FEATURE=$(get_next_feature "$PROJECT_DIR")
    FEATURE_DESC=$(get_feature_description "$PROJECT_DIR" "$NEXT_FEATURE")

    echo ""
    print_separator
    log_step "[会话 $SESSION_COUNT] 特性: $NEXT_FEATURE"
    log_progress "$FEATURE_DESC"
    echo ""

    # 记录会话开始时间
    SESSION_START=$(date +%s)

    # 调用 Claude Code
    if [[ "$VERBOSE" == true ]]; then
        claude --model "$MODEL" "/code-feature"
    else
        claude --model "$MODEL" --print "/code-feature" 2>&1 | while read -r line; do
            echo "  $line"
        done
    fi

    # 记录会话结束时间
    SESSION_END=$(date +%s)
    SESSION_DURATION=$((SESSION_END - SESSION_START))

    # 更新统计
    COMPLETED=$(get_completed_features "$PROJECT_DIR")
    INCOMPLETE=$(get_incomplete_features "$PROJECT_DIR")
    PERCENTAGE=$(get_completion_percentage "$PROJECT_DIR")

    echo ""
    log_success "会话完成 (耗时: ${SESSION_DURATION}秒)"
    log_info "进度: $COMPLETED/$TOTAL ($PERCENTAGE%)"

    # 短暂暂停
    sleep 2
done

# 显示最终统计
END_TIME=$(date +%s)
TOTAL_DURATION=$((END_TIME - START_TIME))
HOURS=$((TOTAL_DURATION / 3600))
MINUTES=$(((TOTAL_DURATION % 3600) / 60))

echo ""
print_separator
print_title "工作流完成"

log_success "所有特性已完成!"
echo ""
print_table_row "总会话数:" "$SESSION_COUNT"
print_table_row "总耗时:" "${HOURS}小时 ${MINUTES}分钟"
print_table_row "总提交:" "$(git -C "$PROJECT_DIR" rev-list --count HEAD 2>/dev/null || echo "N/A")"
