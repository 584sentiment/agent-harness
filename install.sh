#!/usr/bin/env bash
# install.sh - Agent Harness 安装脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 版本
VERSION="1.0.0"

# 安装目录
INSTALL_DIR="$HOME/.agent-harness"
COMMANDS_DIR="$HOME/.claude/commands"

echo -e "${PURPLE}"
cat << "EOF"
   ___            _    _    _
  /   |  ____ _  (_)  / \  | |
 / /| | / __``/ / /  / _ \ | |
/ ___ |/ /_/ / / /  / ___ \| |___
/_/  |_\__,_/_/_/  /_/   \_\_____|
            Harness
EOF
echo -e "${NC}"
echo "长期运行代理工作流框架 v$VERSION"
echo ""

# 检查依赖
echo -e "${BLUE}检查依赖...${NC}"

check_dependency() {
    local dep="$1"
    local name="$2"
    if command -v "$dep" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $name"
        return 0
    else
        echo -e "  ${RED}✗${NC} $name (未找到)"
        return 1
    fi
}

MISSING=0

# 必需依赖
check_dependency "bash" "Bash" || MISSING=$((MISSING + 1))
check_dependency "git" "Git" || MISSING=$((MISSING + 1))
check_dependency "jq" "jq" || MISSING=$((MISSING + 1))

# 可选依赖
check_dependency "claude" "Claude Code CLI" || echo -e "  ${BLUE}→ 可选，但推荐安装${NC}"

if [[ $MISSING -gt 0 ]]; then
    echo ""
    echo -e "${RED}缺少必需依赖，请先安装后再运行此脚本${NC}"
    echo ""
    echo "安装建议:"
    echo "  - jq: https://stedolan.github.io/jq/download/"
    echo "  - git: https://git-scm.com/downloads"
    echo "  - claude: npm install -g @anthropics/claude-code"
    exit 1
fi

echo ""

# 确定脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 如果从仓库运行，复制文件；否则下载
if [[ -f "$SCRIPT_DIR/bin/harness" ]]; then
    echo -e "${BLUE}从本地安装...${NC}"
    cp -r "$SCRIPT_DIR" "$INSTALL_DIR"
else
    echo -e "${BLUE}下载最新版本...${NC}"
    REPO_URL="https://github.com/yourname/agent-harness"
    if command -v git &> /dev/null; then
        git clone "$REPO_URL" "$INSTALL_DIR" --depth 1
    else
        echo -e "${RED}请使用 git clone 安装${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓${NC} 已安装到 $INSTALL_DIR"

# 安装 Claude Code commands
echo ""
echo -e "${BLUE}安装 Claude Code 命令...${NC}"

mkdir -p "$COMMANDS_DIR"

if [[ -f "$INSTALL_DIR/commands/init-harness.md" ]]; then
    cp "$INSTALL_DIR/commands/init-harness.md" "$COMMANDS_DIR/"
    echo -e "${GREEN}✓${NC} /init-harness"
fi

if [[ -f "$INSTALL_DIR/commands/code-feature.md" ]]; then
    cp "$INSTALL_DIR/commands/code-feature.md" "$COMMANDS_DIR/"
    echo -e "${GREEN}✓${NC} /code-feature"
fi

# 设置可执行权限
chmod +x "$INSTALL_DIR/bin/harness"
chmod +x "$INSTALL_DIR/lib/commands"/*.sh 2>/dev/null || true

# 配置 PATH
echo ""
echo -e "${BLUE}配置 PATH...${NC}"

SHELL_RC=""
if [[ -f "$HOME/.bashrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
elif [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
    SHELL_RC="$HOME/.bash_profile"
fi

PATH_LINE='export PATH="$HOME/.agent-harness/bin:$PATH"'

if [[ -n "$SHELL_RC" ]]; then
    if grep -q ".agent-harness/bin" "$SHELL_RC" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} PATH 已配置"
    else
        echo "" >> "$SHELL_RC"
        echo "# Agent Harness" >> "$SHELL_RC"
        echo "$PATH_LINE" >> "$SHELL_RC"
        echo -e "${GREEN}✓${NC} 已添加到 $SHELL_RC"
    fi
else
    echo -e "${BLUE}请手动添加以下内容到你的 shell 配置文件:${NC}"
    echo ""
    echo "  $PATH_LINE"
    echo ""
fi

# 完成
echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}安装完成!${NC}"
echo ""
echo "使用方法:"
echo ""
echo "  # 重新加载 shell 配置"
echo "  source ~/.bashrc  # 或 ~/.zshrc"
echo ""
echo "  # 初始化项目"
echo "  cd your-project"
echo "  harness init \"构建用户认证系统\""
echo ""
echo "  # 运行工作流"
echo "  harness run"
echo ""
echo "  # 查看状态"
echo "  harness status"
echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
