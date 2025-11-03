#!/bin/bash

# MySQL 局域网访问启动脚本
# 用途：启动端口转发，使局域网中的其他机器能够访问 MySQL

echo "🚀 启动 MySQL 局域网访问..."
echo "📍 服务器局域网 IP: 192.168.1.102"
echo "🔌 端口: 30306"

# 检查 MySQL Pod 状态
echo "📊 检查 MySQL Pod 状态..."
kubectl get pods -n mysql

# 检查 MySQL 服务状态
echo "🔍 检查 MySQL 服务状态..."
kubectl get svc -n mysql

# 启动端口转发
echo "🌐 启动端口转发 (0.0.0.0:30306 -> MySQL Service)..."
echo "💡 局域网中的其他机器现在可以通过 192.168.1.102:30306 访问 MySQL"
echo "⚠️  按 Ctrl+C 停止端口转发"
echo ""

# 启动端口转发（前台运行）
kubectl port-forward --address 0.0.0.0 service/mysql-nodeport 30306:3306 -n mysql