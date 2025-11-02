#!/bin/bash

# KubePi 局域网访问启动脚本
# 使用方法: ./start-kubepi-lan.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取本机局域网 IP
get_lan_ip() {
    # 尝试获取局域网 IP（192.168.x.x 或 10.x.x.x）
    LAN_IP=$(hostname -I | tr ' ' '\n' | grep -E '^(192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.)' | head -1)
    if [ -z "$LAN_IP" ]; then
        print_error "无法获取局域网 IP 地址"
        exit 1
    fi
    echo "$LAN_IP"
}

# 检查 KubePi 是否运行
check_kubepi_status() {
    if kubectl get pods -n kubepi -l app=kubepi --no-headers 2>/dev/null | grep -q "Running"; then
        return 0
    else
        return 1
    fi
}

# 启动端口转发
start_port_forward() {
    local lan_ip=$1
    local port=30888
    
    print_info "启动端口转发到所有网络接口..."
    print_info "局域网访问地址: http://${lan_ip}:${port}"
    print_info "按 Ctrl+C 停止端口转发"
    
    # 启动端口转发
    kubectl port-forward --address 0.0.0.0 -n kubepi svc/kubepi-service ${port}:80
}

# 主函数
main() {
    print_info "=== KubePi 局域网访问启动脚本 ==="
    
    # 检查 kubectl 连接
    if ! kubectl cluster-info &>/dev/null; then
        print_error "无法连接到 Kubernetes 集群"
        exit 1
    fi
    
    # 检查 KubePi 是否运行
    if ! check_kubepi_status; then
        print_error "KubePi 未运行，请先部署 KubePi"
        print_info "运行: kubectl apply -f kubepi-deploy.yaml"
        exit 1
    fi
    
    print_success "KubePi 运行正常"
    
    # 获取局域网 IP
    LAN_IP=$(get_lan_ip)
    print_success "检测到局域网 IP: $LAN_IP"
    
    # 启动端口转发
    start_port_forward "$LAN_IP"
}

# 运行主函数
main "$@"