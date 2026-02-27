#!/usr/bin/env bash
# status.sh - 显示项目状态

set -e

# 加载工具函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/features.sh"
source "$SCRIPT_DIR/../utils/validate.sh"

# 帮助信息
show_help() {
    cat << EOF
用法: harness status [选项]

显示当前项目状态。

选项:
  -j, --json          JSON 格式输出
  --features          显示所有特性详情
  -h, --help          显示帮助信息

示例:
  harness status
  harness status --json
  harness status --features
EOF
}

# 解析参数
JSON_OUTPUT=false
SHOW_FEATURES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -j|--json)
            JSON_OUTPUT=true
            shift
            ;;
        --features)
            SHOW_FEATURES=true
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

if ! check_agent_dir "$PROJECT_DIR"; then
    log_error "当前目录不是 Agent Harness 项目"
    log_info "请先运行 'harness init <描述>' 初始化项目"
    exit 3
fi

if ! check_features_file "$PROJECT_DIR"; then
    log_error "缺少 feature_list.json"
    exit 2
fi

# JSON 输出
if [[ "$JSON_OUTPUT" == true ]]; then
    FEATURES_FILE="$PROJECT_DIR/.agent/feature_list.json"
    TOTAL=$(get_total_features "$PROJECT_DIR")
    COMPLETED=$(get_completed_features "$PROJECT_DIR")
    PERCENTAGE=$(get_completion_percentage "$PROJECT_DIR")

    jq -n \
        --argjson total "$TOTAL" \
        --argjson completed "$COMPLETED" \
        --argjson percentage "$PERCENTAGE" \
        --arg project_dir "$PROJECT_DIR" \
        --slurpfile features "$FEATURES_FILE" \
        '{
            project_dir: $project_dir,
            total: $total,
            completed: $completed,
            incomplete: ($total - $completed),
            percentage: $percentage,
            features: $features[0].features
        }'
    exit 0
fi

# 获取项目信息
PROJECT_NAME=$(get_project_name "$PROJECT_DIR")
TOTAL=$(get_total_features "$PROJECT_DIR")
COMPLETED=$(get_completed_features "$PROJECT_DIR")
INCOMPLETE=$(get_incomplete_features "$PROJECT_DIR")
PERCENTAGE=$(get_completion_percentage "$PROJECT_DIR")
NEXT_FEATURE=$(get_next_feature "$PROJECT_DIR")

# 获取 git 信息
LAST_COMMIT=""
if is_git_repo "$PROJECT_DIR"; then
    LAST_COMMIT=$(git -C "$PROJECT_DIR" log -1 --format="%h %s" 2>/dev/null | head -1)
fi

# 获取最后更新时间
PROGRESS_FILE="$PROJECT_DIR/.agent/progress.md"
LAST_UPDATE=""
if [[ -f "$PROGRESS_FILE" ]]; then
    LAST_UPDATE=$(stat -c %y "$PROGRESS_FILE" 2>/dev/null || stat -f "%Sm" "$PROGRESS_FILE" 2>/dev/null)
fi

# 显示状态
print_title "项目状态"

echo "项目: $PROJECT_NAME"
echo "目录: $PROJECT_DIR"
echo ""

# 进度条
BAR_WIDTH=40
FILLED=$((PERCENTAGE * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))

printf "进度: ["
printf "%0.s█" $(seq 1 $FILLED 2>/dev/null) || printf "%0.s█" $( jot 1 $FILLED 2>/dev/null )
printf "%0.s░" $(seq 1 $EMPTY 2>/dev/null) || printf "%0.s░" $( jot 1 $EMPTY 2>/dev/null )
printf "] %d%%\n\n" "$PERCENTAGE"

echo "统计:"
echo "  ✓ 已完成: $COMPLETED/$TOTAL"
echo "  ○ 进行中: $([[ -n \"$NEXT_FEATURE\" ]] && echo \"1\" || echo \"0\")"
echo "  ✗ 待处理: $INCOMPLETE"
echo ""

if [[ -n "$NEXT_FEATURE" ]]; then
    FEATURE_DESC=$(get_feature_description "$PROJECT_DIR" "$NEXT_FEATURE")
    echo "当前特性: $NEXT_FEATURE"
    echo "  $FEATURE_DESC"
    echo ""
fi

if [[ -n "$LAST_UPDATE" ]]; then
    echo "最后更新: $LAST_UPDATE"
fi

if [[ -n "$LAST_COMMIT" ]]; then
    echo "最近提交: $LAST_COMMIT"
fi

# 显示所有特性
if [[ "$SHOW_FEATURES" == true ]]; then
    echo ""
    print_separator
    echo ""
    echo "所有特性:"
    echo ""

    # 使用 Python 显示特性列表
    local native_dir=$(cd "$PROJECT_DIR" && pwd -W 2>/dev/null || echo "$PROJECT_DIR")
    python -c "
import json
import sys
import os
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
os.chdir(r'$native_dir')
data = json.load(open('.agent/feature_list.json', encoding='utf-8'))
for f in data.get('features', []):
    status = '✓' if f.get('passes') else '✗'
    print(f'  {status} {f[\"id\"]}: {f[\"description\"]}')
" 2>/dev/null
fi
