#!/bin/bash

# TestHub 服务启动脚本

echo "=== TestHub 服务启动脚本 ==="
echo ""

# 激活虚拟环境并启动后端
echo "1. 启动 Django 后端服务..."
cd /workspace
source venv/bin/activate
nohup python manage.py runserver 0.0.0.0:9999 > /tmp/backend.log 2>&1 &
BACKEND_PID=$!
echo "   后端服务 PID: $BACKEND_PID"

# 等待后端启动
sleep 5

# 检查后端是否成功启动
if lsof -i :9999 > /dev/null 2>&1; then
    echo "   ✅ 后端服务启动成功 (端口 9999)"
else
    echo "   ❌ 后端服务启动失败"
    tail -20 /tmp/backend.log
fi

# 启动前端
echo ""
echo "2. 启动 Vue 前端服务..."
cd /workspace/frontend
nohup npm run dev > /tmp/frontend.log 2>&1 &
FRONTEND_PID=$!
echo "   前端服务 PID: $FRONTEND_PID"

# 等待前端启动
sleep 3

# 检查前端是否成功启动
if lsof -i :9090 > /dev/null 2>&1; then
    echo "   ✅ 前端服务启动成功 (端口 9090)"
else
    echo "   ❌ 前端服务启动失败"
    tail -20 /tmp/frontend.log
fi

# 验证服务状态
echo ""
echo "3. 验证服务状态..."
sleep 2

echo ""
echo "=== 服务状态 ==="
ss -tlnp | grep -E ":9999|:9090"

echo ""
echo "=== 访问地址 ==="
echo "前端应用: http://localhost:9090/"
echo "后端 API: http://localhost:9999/"
echo "API 文档: http://localhost:9999/api/docs/"

echo ""
echo "✅ 所有服务已启动"
