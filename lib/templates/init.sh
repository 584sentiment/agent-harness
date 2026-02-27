#!/usr/bin/env bash
# init.sh - 项目环境启动脚本
# 由 Initializer Agent 自动生成

# 项目类型: {{PROJECT_TYPE}}
# 生成时间: {{CREATED_DATE}}

set -e

echo "启动开发环境..."

# 根据项目类型启动相应的开发服务器
PROJECT_TYPE="{{PROJECT_TYPE}}"

case "$PROJECT_TYPE" in
    node)
        echo "检测到 Node.js 项目"
        if [[ -f "package.json" ]]; then
            if ! command -v npm &> /dev/null; then
                echo "错误: 未找到 npm"
                exit 1
            fi
            # 安装依赖（如果需要）
            if [[ ! -d "node_modules" ]]; then
                echo "安装依赖..."
                npm install
            fi
            # 启动开发服务器
            echo "启动开发服务器..."
            npm run dev &
            sleep 3
        fi
        ;;
    python)
        echo "检测到 Python 项目"
        if [[ -f "requirements.txt" ]]; then
            # 创建虚拟环境（如果不存在）
            if [[ ! -d "venv" ]]; then
                echo "创建虚拟环境..."
                python -m venv venv
            fi
            # 激活虚拟环境并安装依赖
            source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null
            pip install -r requirements.txt -q
        fi
        ;;
    go)
        echo "检测到 Go 项目"
        # 下载依赖
        go mod download
        # 构建项目
        go build -o bin/app ./...
        ;;
    *)
        echo "通用项目类型，跳过自动配置"
        ;;
esac

echo "开发环境就绪!"
