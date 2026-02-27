#!/usr/bin/env bash
# logging.sh - 日志和输出工具

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 符号定义
CHECK="✓"
CROSS="✗"
ARROW="→"
DOT="○"

# 日志函数
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}${CHECK}${NC} $1"
}

log_error() {
    echo -e "${RED}${CROSS}${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

log_step() {
    echo -e "${CYAN}${ARROW}${NC} $1"
}

log_progress() {
    echo -e "${DOT} $1"
}

# 打印标题
print_title() {
    echo ""
    echo -e "${PURPLE}Agent Harness${NC} - $1"
    echo -e "${PURPLE}$(printf '━%.0s' {1..40})${NC}"
    echo ""
}

# 打印分隔线
print_separator() {
    echo -e "${PURPLE}$(printf '━%.0s' {1..40})${NC}"
}

# 打印表格行
print_table_row() {
    local col1="$1"
    local col2="$2"
    printf "  %-20s %s\n" "$col1" "$col2"
}
