#!/usr/bin/env bash
# validate.sh - 验证工具

# 检查依赖
check_dependencies() {
    local missing=()

    # 检查 jq
    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi

    # 检查 git
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi

    # 检查 claude CLI
    if ! command -v claude &> /dev/null; then
        missing+=("claude (Claude Code CLI)")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "缺少依赖:"
        for dep in "${missing[@]}"; do
            echo "  - $dep"
        done
        return 1
    fi

    return 0
}

# 检查是否在 git 仓库中
is_git_repo() {
    local dir="${1:-$(pwd)}"
    git -C "$dir" rev-parse --git-dir &> /dev/null
}

# 检查是否在项目目录
is_project_dir() {
    local dir="${1:-$(pwd)}"

    # 检查是否有常见项目文件
    [[ -f "$dir/package.json" ]] || \
    [[ -f "$dir/requirements.txt" ]] || \
    [[ -f "$dir/go.mod" ]] || \
    [[ -f "$dir/Cargo.toml" ]] || \
    [[ -f "$dir/pom.xml" ]] || \
    [[ -f "$dir/build.gradle" ]] || \
    [[ -d "$dir/src" ]] || \
    [[ -d "$dir/lib" ]]
}

# 检测项目类型
detect_project_type() {
    local dir="${1:-$(pwd)}"

    if [[ -f "$dir/package.json" ]]; then
        echo "node"
    elif [[ -f "$dir/requirements.txt" ]] || [[ -f "$dir/pyproject.toml" ]]; then
        echo "python"
    elif [[ -f "$dir/go.mod" ]]; then
        echo "go"
    elif [[ -f "$dir/Cargo.toml" ]]; then
        echo "rust"
    elif [[ -f "$dir/pom.xml" ]] || [[ -f "$dir/build.gradle" ]]; then
        echo "java"
    else
        echo "generic"
    fi
}

# 验证 feature_list.json 格式
validate_features_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "文件不存在: $file"
        return 1
    fi

    # 检查是否是有效 JSON
    if ! jq empty "$file" 2>/dev/null; then
        echo "无效的 JSON 格式"
        return 1
    fi

    # 检查必需字段
    local has_features=$(jq 'has("features")' "$file" 2>/dev/null)
    if [[ "$has_features" != "true" ]]; then
        echo "缺少 features 字段"
        return 1
    fi

    return 0
}

# 检查 .agent 目录结构
validate_agent_dir() {
    local dir="${1:-$(pwd)}"
    local agent_dir="$dir/.agent"

    if [[ ! -d "$agent_dir" ]]; then
        echo ".agent 目录不存在"
        return 1
    fi

    if [[ ! -f "$agent_dir/feature_list.json" ]]; then
        echo "缺少 feature_list.json"
        return 1
    fi

    if [[ ! -f "$agent_dir/progress.md" ]]; then
        echo "缺少 progress.md"
        return 1
    fi

    if [[ ! -f "$agent_dir/init.sh" ]]; then
        echo "缺少 init.sh"
        return 1
    fi

    return 0
}
