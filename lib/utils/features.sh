#!/usr/bin/env bash
# features.sh - 特性列表操作工具

# 检测 JSON 处理工具
detect_json_tool() {
    if command -v jq &> /dev/null; then
        echo "jq"
    elif command -v python &> /dev/null || command -v python3 &> /dev/null; then
        echo "python"
    else
        echo "none"
    fi
}

JSON_TOOL=$(detect_json_tool)

# 获取 Windows 兼容路径
get_native_path() {
    local path="$1"
    # 在 Git Bash/MINGW 环境中使用 pwd -W 获取 Windows 路径
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        if [[ -d "$path" ]]; then
            (cd "$path" && pwd -W) 2>/dev/null || echo "$path"
        else
            echo "$path"
        fi
    else
        echo "$path"
    fi
}

# Python JSON 辅助函数 - 使用转换后的路径
_py_json() {
    local dir="$1"
    local code="$2"
    shift 2

    local python_cmd="python"
    if command -v python &> /dev/null; then
        python_cmd="python"
    elif command -v python3 &> /dev/null; then
        python_cmd="python3"
    fi

    # 转换为原生路径
    local native_dir=$(get_native_path "$dir")

    "$python_cmd" -c "
import json
import sys
import os

# 确保输出使用 UTF-8
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

# 切换到目标目录
os.chdir(r'$native_dir')

$code
" 2>/dev/null
}

# 获取特性列表文件路径
get_features_file() {
    local dir="${1:-$(pwd)}"
    echo "$dir/.agent/feature_list.json"
}

# 获取进度文件路径
get_progress_file() {
    local dir="${1:-$(pwd)}"
    echo "$dir/.agent/progress.md"
}

# 检查 .agent 目录是否存在
check_agent_dir() {
    local dir="${1:-$(pwd)}"
    [[ -d "$dir/.agent" ]]
}

# 检查 feature_list.json 是否存在
check_features_file() {
    local dir="${1:-$(pwd)}"
    local file="$dir/.agent/feature_list.json"
    [[ -f "$file" ]]
}

# 获取特性总数
get_total_features() {
    local dir="${1:-$(pwd)}"

    if [[ ! -f "$dir/.agent/feature_list.json" ]]; then
        echo "0"
        return
    fi

    case "$JSON_TOOL" in
        jq)
            jq '.features | length' "$dir/.agent/feature_list.json" 2>/dev/null || echo "0"
            ;;
        python)
            _py_json "$dir" "
data = json.load(open('.agent/feature_list.json', encoding='utf-8'))
print(len(data.get('features', [])))
"
            ;;
        *)
            echo "0"
            ;;
    esac
}

# 获取已完成特性数
get_completed_features() {
    local dir="${1:-$(pwd)}"

    if [[ ! -f "$dir/.agent/feature_list.json" ]]; then
        echo "0"
        return
    fi

    case "$JSON_TOOL" in
        jq)
            jq '[.features[] | select(.passes == true)] | length' "$dir/.agent/feature_list.json" 2>/dev/null || echo "0"
            ;;
        python)
            _py_json "$dir" "
data = json.load(open('.agent/feature_list.json', encoding='utf-8'))
print(sum(1 for f in data.get('features', []) if f.get('passes')))
"
            ;;
        *)
            echo "0"
            ;;
    esac
}

# 获取未完成特性数
get_incomplete_features() {
    local dir="${1:-$(pwd)}"

    if [[ ! -f "$dir/.agent/feature_list.json" ]]; then
        echo "0"
        return
    fi

    case "$JSON_TOOL" in
        jq)
            jq '[.features[] | select(.passes == false)] | length' "$dir/.agent/feature_list.json" 2>/dev/null || echo "0"
            ;;
        python)
            _py_json "$dir" "
data = json.load(open('.agent/feature_list.json', encoding='utf-8'))
print(sum(1 for f in data.get('features', []) if not f.get('passes')))
"
            ;;
        *)
            echo "0"
            ;;
    esac
}

# 检查是否还有未完成特性
has_incomplete_features() {
    local dir="${1:-$(pwd)}"
    local count=$(get_incomplete_features "$dir")
    [[ "$count" -gt 0 ]]
}

# 获取第一个未完成的特性
get_next_feature() {
    local dir="${1:-$(pwd)}"

    if [[ ! -f "$dir/.agent/feature_list.json" ]]; then
        return
    fi

    case "$JSON_TOOL" in
        jq)
            jq -r '.features[] | select(.passes == false) | .id' "$dir/.agent/feature_list.json" 2>/dev/null | head -1
            ;;
        python)
            _py_json "$dir" "
data = json.load(open('.agent/feature_list.json', encoding='utf-8'))
features = [f for f in data.get('features', []) if not f.get('passes')]
print(features[0]['id'] if features else '')
"
            ;;
    esac
}

# 获取特性详情
get_feature_by_id() {
    local dir="${1:-$(pwd)}"
    local id="$2"

    if [[ ! -f "$dir/.agent/feature_list.json" ]]; then
        return
    fi

    case "$JSON_TOOL" in
        jq)
            jq -r --arg id "$id" '.features[] | select(.id == $id)' "$dir/.agent/feature_list.json" 2>/dev/null
            ;;
        python)
            _py_json "$dir" "
data = json.load(open('.agent/feature_list.json', encoding='utf-8'))
f = next((f for f in data.get('features', []) if f.get('id')=='$id'), None)
print(json.dumps(f, ensure_ascii=False) if f else '')
"
            ;;
    esac
}

# 获取特性描述
get_feature_description() {
    local dir="${1:-$(pwd)}"
    local id="$2"

    if [[ ! -f "$dir/.agent/feature_list.json" ]]; then
        return
    fi

    case "$JSON_TOOL" in
        jq)
            jq -r --arg id "$id" '.features[] | select(.id == $id) | .description' "$dir/.agent/feature_list.json" 2>/dev/null
            ;;
        python)
            _py_json "$dir" "
data = json.load(open('.agent/feature_list.json', encoding='utf-8'))
f = next((f for f in data.get('features', []) if f.get('id')=='$id'), None)
print(f.get('description','') if f else '')
"
            ;;
    esac
}

# 标记特性为完成
mark_feature_complete() {
    local dir="${1:-$(pwd)}"
    local id="$2"

    if [[ ! -f "$dir/.agent/feature_list.json" ]]; then
        return
    fi

    local completed_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    case "$JSON_TOOL" in
        jq)
            local tmp_file=$(mktemp)
            jq --arg id "$id" --arg completed "$completed_date" \
               '(.features[] | select(.id == $id)) |= (.passes = true | .completed_at = $completed)' \
               "$dir/.agent/feature_list.json" > "$tmp_file" && mv "$tmp_file" "$dir/.agent/feature_list.json"
            ;;
        python)
            _py_json "$dir" "
data = json.load(open('.agent/feature_list.json', encoding='utf-8'))
for feature in data.get('features', []):
    if feature.get('id') == '$id':
        feature['passes'] = True
        feature['completed_at'] = '$completed_date'
with open('.agent/feature_list.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
"
            ;;
    esac
}

# 获取项目名称
get_project_name() {
    local dir="${1:-$(pwd)}"

    if [[ ! -f "$dir/.agent/feature_list.json" ]]; then
        echo "未命名项目"
        return
    fi

    case "$JSON_TOOL" in
        jq)
            jq -r '.project.name // "未命名项目"' "$dir/.agent/feature_list.json" 2>/dev/null
            ;;
        python)
            _py_json "$dir" "
data = json.load(open('.agent/feature_list.json', encoding='utf-8'))
print(data.get('project',{}).get('name','未命名项目'))
"
            ;;
        *)
            echo "未命名项目"
            ;;
    esac
}

# 获取项目信息
get_project_info() {
    local dir="${1:-$(pwd)}"

    if [[ ! -f "$dir/.agent/feature_list.json" ]]; then
        return
    fi

    case "$JSON_TOOL" in
        jq)
            jq -r '.project' "$dir/.agent/feature_list.json" 2>/dev/null
            ;;
        python)
            _py_json "$dir" "
data = json.load(open('.agent/feature_list.json', encoding='utf-8'))
print(json.dumps(data.get('project',{}), ensure_ascii=False))
"
            ;;
    esac
}

# 获取未完成特性列表
list_incomplete_features() {
    local dir="${1:-$(pwd)}"

    if [[ ! -f "$dir/.agent/feature_list.json" ]]; then
        return
    fi

    case "$JSON_TOOL" in
        jq)
            jq -r '.features[] | select(.passes == false) | "\(.id) | \(.description)"' "$dir/.agent/feature_list.json" 2>/dev/null
            ;;
        python)
            _py_json "$dir" "
data = json.load(open('.agent/feature_list.json', encoding='utf-8'))
for f in data.get('features', []):
    if not f.get('passes'):
        print(f\"{f['id']} | {f['description']}\")
"
            ;;
    esac
}

# 计算完成百分比
get_completion_percentage() {
    local dir="${1:-$(pwd)}"
    local total=$(get_total_features "$dir")
    local completed=$(get_completed_features "$dir")

    if [[ "$total" -gt 0 ]]; then
        echo $(( completed * 100 / total ))
    else
        echo "0"
    fi
}
