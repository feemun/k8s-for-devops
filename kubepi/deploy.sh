#!/bin/bash

# KubePi 一键部署脚本
# 使用方法: ./deploy.sh [nodeport|loadbalancer|ingress]

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

# 检查 kubectl 是否可用
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl 未找到，请先安装 kubectl"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        print_error "无法连接到 Kubernetes 集群，请检查 kubeconfig"
        exit 1
    fi
    
    print_success "kubectl 连接正常"
}

# 部署 KubePi
deploy_kubepi() {
    print_info "开始部署 KubePi..."
    
    if [ ! -f "kubepi-deploy.yaml" ]; then
        print_error "kubepi-deploy.yaml 文件不存在"
        exit 1
    fi
    
    kubectl apply -f kubepi-deploy.yaml
    print_success "KubePi 配置已应用"
}

# 等待 Pod 就绪
wait_for_pods() {
    print_info "等待 KubePi Pod 启动..."
    kubectl wait --for=condition=ready pod -l app=kubepi -n kubepi --timeout=300s
    print_success "KubePi Pod 已就绪"
}

# 配置 NodePort 访问
setup_nodeport() {
    print_info "配置 NodePort 访问..."
    
    cat > kubepi-nodeport.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: kubepi-nodeport
  namespace: kubepi
  labels:
    app: kubepi
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
    name: http
  selector:
    app: kubepi
EOF
    
    kubectl apply -f kubepi-nodeport.yaml
    print_success "NodePort 服务已创建"
    
    # 获取访问信息
    print_info "获取访问信息..."
    NODE_IPS=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}')
    
    echo ""
    print_success "=== KubePi 访问信息 ==="
    echo -e "${GREEN}访问方式: NodePort${NC}"
    echo -e "${GREEN}端口: 30080${NC}"
    echo -e "${GREEN}访问地址:${NC}"
    for ip in $NODE_IPS; do
        echo -e "  ${BLUE}http://$ip:30080${NC}"
    done
    echo ""
}

# 配置 LoadBalancer 访问
setup_loadbalancer() {
    print_info "配置 LoadBalancer 访问..."
    kubectl patch svc kubepi-service -n kubepi -p '{"spec":{"type":"LoadBalancer"}}'
    
    print_info "等待 LoadBalancer IP 分配..."
    sleep 10
    
    EXTERNAL_IP=$(kubectl get svc kubepi-service -n kubepi -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    
    if [ -z "$EXTERNAL_IP" ] || [ "$EXTERNAL_IP" = "null" ]; then
        print_warning "LoadBalancer IP 尚未分配，请稍后检查"
        print_info "使用以下命令检查状态:"
        echo "kubectl get svc kubepi-service -n kubepi"
    else
        print_success "=== KubePi 访问信息 ==="
        echo -e "${GREEN}访问方式: LoadBalancer${NC}"
        echo -e "${GREEN}访问地址: ${BLUE}http://$EXTERNAL_IP${NC}"
    fi
}

# 显示状态信息
show_status() {
    print_info "=== 部署状态 ==="
    echo ""
    
    print_info "Namespace 状态:"
    kubectl get ns kubepi
    echo ""
    
    print_info "Pod 状态:"
    kubectl get pods -n kubepi
    echo ""
    
    print_info "Service 状态:"
    kubectl get svc -n kubepi
    echo ""
    
    print_info "PVC 状态:"
    kubectl get pvc -n kubepi
    echo ""
}

# 获取登录信息
get_login_info() {
    print_info "获取登录信息..."
    
    # 等待一下让日志生成
    sleep 5
    
    print_success "=== 登录信息 ==="
    echo -e "${GREEN}默认用户名: ${BLUE}admin${NC}"
    echo -e "${GREEN}默认密码: ${BLUE}kubepi123${NC} ${YELLOW}(请登录后立即修改)${NC}"
    echo ""
    
    print_info "如需查看实际初始密码，请执行:"
    echo "kubectl logs deployment/kubepi -n kubepi | grep -i password"
}

# 清理资源
cleanup() {
    print_warning "开始清理 KubePi 资源..."
    
    if kubectl get namespace kubepi &> /dev/null; then
        kubectl delete -f kubepi-deploy.yaml 2>/dev/null || true
        kubectl delete -f kubepi-nodeport.yaml 2>/dev/null || true
        print_success "KubePi 资源已清理"
    else
        print_info "KubePi 未部署，无需清理"
    fi
}

# 显示帮助信息
show_help() {
    echo "KubePi 部署脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [选项]"
    echo ""
    echo "选项:"
    echo "  nodeport      - 使用 NodePort 方式部署（推荐用于局域网访问）"
    echo "  loadbalancer  - 使用 LoadBalancer 方式部署"
    echo "  ingress       - 使用 Ingress 方式部署"
    echo "  status        - 显示当前部署状态"
    echo "  cleanup       - 清理所有 KubePi 资源"
    echo "  help          - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 nodeport     # 部署并配置 NodePort 访问"
    echo "  $0 status       # 查看部署状态"
    echo "  $0 cleanup      # 清理资源"
}

# 主函数
main() {
    case "${1:-nodeport}" in
        "nodeport")
            check_kubectl
            deploy_kubepi
            wait_for_pods
            setup_nodeport
            show_status
            get_login_info
            ;;
        "loadbalancer")
            check_kubectl
            deploy_kubepi
            wait_for_pods
            setup_loadbalancer
            show_status
            get_login_info
            ;;
        "ingress")
            check_kubectl
            deploy_kubepi
            wait_for_pods
            print_info "Ingress 已在 kubepi-deploy.yaml 中配置，请根据需要修改域名"
            show_status
            get_login_info
            ;;
        "status")
            check_kubectl
            show_status
            ;;
        "cleanup")
            check_kubectl
            cleanup
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"