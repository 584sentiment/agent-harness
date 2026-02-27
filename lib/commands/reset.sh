#!/usr/bin/env bash
# reset.sh - 重置工作流状态

set -e

# 加载工具函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/features.sh"
source "$SCRIPT_DIR/../utils/validate.sh"

# 帮助信息
show_help() {
    cat << EOF
用法: harness reset [选项]

重置工作流状态。

选项:
  --features          重置所有特性为未完成
  --progress          清空进度日志
  --all               完全重置
  -y, --yes           跳过确认
  -h, --help          显示帮助信息

示例:
  harness reset --features
  harness reset --all -y
EOF
}

# 解析参数
RESET_FEATURES=false
RESET_PROGRESS=false
RESET_ALL=false
SKIP_CONFIRM=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --features)
            RESET_FEATURES=true
            shift
            ;;
        --progress)
            RESET_PROGRESS=true
            shift
            ;;
        --all)
            RESET_ALL=true
            shift
            ;;
        -y|--yes)
            SKIP_CONFIRM=true
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
    exit 3
fi

# 如果没有指定任何选项，显示帮助
if [[ "$RESET_FEATURES" == false ]] && [[ "$RESET_PROGRESS" == false ]] && [[ "$RESET_ALL" == false ]]; then
    show_help
    exit 0
fi

# 确认操作
if [[ "$SKIP_CONFIRM" != true ]]; then
    if [[ "$RESET_ALL" == true ]]; then
        log_warning "将完全重置工作流状态（包括特性状态和进度日志）"
    else
        [[ "$RESET_FEATURES" == true ]] && log_warning "将重置所有特性为未完成"
        [[ "$RESET_PROGRESS" == true ]] && log_warning "将清空进度日志"
    fi

    read -p "确认继续? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "操作已取消"
        exit 5
    fi
fi

# 执行重置
if [[ "$RESET_ALL" == true ]]; then
    RESET_FEATURES=true
    RESET_PROGRESS=true
fi

if [[ "$RESET_FEATURES" == true ]]; then
    FEATURES_FILE="$PROJECT_DIR/.agent/feature_list.json"
    if [[ -f "$FEATURES_FILE" ]]; then
        # 使用 Python 替代 jq
        local native_dir=$(cd "$PROJECT_DIR" && pwd -W 2>/dev/null || echo "$PROJECT_DIR")
        python -c "
import json
import os
os.chdir(r'$native_dir')
data = json.load(open('.agent/feature_list.json', encoding='utf-8'))
for feature in data.get('features', []):
    if feature.get('passes'):
        feature['passes'] = False
        feature['completed_at'] = None
with open('.agent/feature_list.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
" 2>/dev/null
        log_success "已重置所有特性为未完成"
    fi
fi

if [[ "$RESET_PROGRESS" == true ]]; then
    PROGRESS_FILE="$PROJECT_DIR/.agent/progress.md"
    PROJECT_NAME=$(get_project_name "$PROJECT_DIR")
    cat > "$PROGRESS_FILE" << EOF
# 开发进度日志

> 项目: $PROJECT_NAME
> 创建: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
> 重置: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

---

*进度日志已重置*
EOF
    log_success "已清空进度日志"
fi

log_info "重置完成"
