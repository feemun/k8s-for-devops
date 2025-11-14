#!/usr/bin/env bash
# 一键暂停 MySQL 服务（Pod 全部回收，数据保留）

set -e
NAMESPACE="mysql"
DEPLOYMENT="mysql"

echo "🛑 正在暂停 MySQL 服务..."
kubectl scale deployment "$DEPLOYMENT" --replicas=0 -n "$NAMESPACE"

echo "⏳ 等待 Pod 终止..."
kubectl wait --for=delete pod -l app=mysql -n "$NAMESPACE" --timeout=60s || true

echo "✅ MySQL 已暂停（Pod 删除，Service/PVC/Secret 保留）"