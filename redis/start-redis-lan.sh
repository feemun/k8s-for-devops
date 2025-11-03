#!/bin/bash

# Redis 局域网访问启动脚本
# 作者: k8s-for-devops
# 版本: 1.0
# 描述: 启动 Redis 服务并配置局域网访问

set -e

echo "=========================================="
echo "Redis 局域网访问启动脚本"
echo "=========================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查 kubectl 是否可用
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}错误: kubectl 未安装或不在 PATH 中${NC}"
    exit 1
fi

# 检查 Kubernetes 集群连接
echo -e "${BLUE}检查 Kubernetes 集群连接...${NC}"
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}错误: 无法连接到 Kubernetes 集群${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Kubernetes 集群连接正常${NC}"

# 部署 Redis 服务
echo -e "${BLUE}部署 Redis 服务...${NC}"
kubectl apply -f "$(dirname "$0")/redis-deploy.yaml"

# 等待 Pod 启动
echo -e "${BLUE}等待 Redis Pod 启动...${NC}"
kubectl wait --for=condition=ready pod -l app=redis -n redis-service --timeout=300s

# 获取服务信息
echo -e "${BLUE}获取服务信息...${NC}"
NODEPORT=$(kubectl get svc redis-nodeport -n redis-service -o jsonpath='{.spec.ports[0].nodePort}')
CLUSTER_IP=$(kubectl get svc redis-service -n redis-service -o jsonpath='{.spec.clusterIP}')

# 获取节点 IP
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

echo -e "${GREEN}=========================================="
echo -e "Redis 服务启动成功！"
echo -e "=========================================="
echo -e "集群内访问地址: ${CLUSTER_IP}:6379"
echo -e "局域网访问地址: ${NODE_IP}:${NODEPORT}"
echo -e "NodePort 端口: ${NODEPORT}"
echo -e "=========================================="

# 显示 Pod 状态
echo -e "${BLUE}Redis Pod 状态:${NC}"
kubectl get pods -n redis-service -l app=redis

echo ""
echo -e "${BLUE}Redis 服务状态:${NC}"
kubectl get svc -n redis-service

echo ""
echo -e "${YELLOW}连接测试命令:${NC}"
echo -e "redis-cli -h ${NODE_IP} -p ${NODEPORT}"
echo -e "或者在集群内: redis-cli -h ${CLUSTER_IP} -p 6379"

echo ""
echo -e "${GREEN}Redis 服务已成功启动并可通过局域网访问！${NC}"