#!/bin/bash

# Redis 外网访问启动脚本
# 作者: k8s-for-devops
# 版本: 1.0
# 描述: 启动 Redis 服务并配置外网访问

set -e

echo "=========================================="
echo "Redis 外网访问启动脚本"
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

# 获取主机 IP 地址
HOST_IP=$(hostname -I | awk '{print $1}')
EXTERNAL_PORT=16379

# 检查端口是否被占用
if netstat -tuln | grep -q ":${EXTERNAL_PORT} "; then
    echo -e "${YELLOW}警告: 端口 ${EXTERNAL_PORT} 已被占用，尝试停止现有的端口转发...${NC}"
    pkill -f "kubectl port-forward.*redis-service.*${EXTERNAL_PORT}" || true
    sleep 2
fi

# 启动端口转发 (后台运行)
echo -e "${BLUE}启动端口转发到外网...${NC}"
nohup kubectl port-forward --address 0.0.0.0 -n redis-service svc/redis-service ${EXTERNAL_PORT}:6379 > /tmp/redis-port-forward.log 2>&1 &
PORT_FORWARD_PID=$!

# 等待端口转发启动
sleep 3

# 检查端口转发是否成功
if ! netstat -tuln | grep -q ":${EXTERNAL_PORT} "; then
    echo -e "${RED}错误: 端口转发启动失败${NC}"
    echo -e "${YELLOW}查看日志: cat /tmp/redis-port-forward.log${NC}"
    exit 1
fi

echo -e "${GREEN}=========================================="
echo -e "Redis 外网访问配置成功！"
echo -e "=========================================="
echo -e "外网访问地址: ${HOST_IP}:${EXTERNAL_PORT}"
echo -e "局域网访问地址: ${HOST_IP}:${EXTERNAL_PORT}"
echo -e "端口转发 PID: ${PORT_FORWARD_PID}"
echo -e "=========================================="

# 显示 Pod 状态
echo -e "${BLUE}Redis Pod 状态:${NC}"
kubectl get pods -n redis-service -l app=redis

echo ""
echo -e "${BLUE}Redis 服务状态:${NC}"
kubectl get svc -n redis-service

echo ""
echo -e "${YELLOW}连接测试命令:${NC}"
echo -e "redis-cli -h ${HOST_IP} -p ${EXTERNAL_PORT}"
echo -e "或者: telnet ${HOST_IP} ${EXTERNAL_PORT}"

echo ""
echo -e "${YELLOW}停止端口转发命令:${NC}"
echo -e "kill ${PORT_FORWARD_PID}"
echo -e "或者: pkill -f 'kubectl port-forward.*redis-service'"

echo ""
echo -e "${GREEN}Redis 服务已成功启动并可通过外网访问！${NC}"
echo -e "${BLUE}端口转发日志: /tmp/redis-port-forward.log${NC}"