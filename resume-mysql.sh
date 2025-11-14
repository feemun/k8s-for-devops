#!/usr/bin/env bash
# 一键恢复 MySQL 服务（重新创建 Pod，数据自动挂载）

set -e
NAMESPACE="mysql"
DEPLOYMENT="mysql"

echo "▶️  正在恢复 MySQL 服务..."
kubectl scale deployment "$DEPLOYMENT" --replicas=1 -n "$NAMESPACE"

echo "⏳ 等待 Pod 启动..."
kubectl wait --for=condition=ready pod -l app=mysql -n "$NAMESPACE" --timeout=120s

echo "✅ MySQL 已恢复（Pod 就绪，外部端口 30306 可访问）"