#!/bin/bash

# Kibana 8.11.0 局域网访问启动脚本
# 与 Elasticsearch 8.11.0 集成

echo "=== Kibana 8.11.0 局域网访问脚本 ==="
echo "时间: $(date)"
echo ""

# 检查 Kibana Pod 状态
echo "1. 检查 Kibana Pod 状态..."
kubectl get pods -n kibana
echo ""

# 检查 Kibana 服务状态
echo "2. 检查 Kibana 服务状态..."
kubectl get svc -n kibana
echo ""

# 获取 Minikube IP
MINIKUBE_IP=$(minikube ip)
echo "3. Minikube IP: $MINIKUBE_IP"
echo ""

# 显示访问信息
echo "=== Kibana 访问信息 ==="
echo "NodePort 访问 (外部机器):"
echo "  URL: http://$MINIKUBE_IP:30561"
echo ""
echo "端口转发访问 (本机):"
echo "  URL: http://localhost:5601"
echo ""

# 检查 Elasticsearch 连接
echo "4. 检查 Elasticsearch 连接状态..."
kubectl get pods -n elasticsearch
echo ""

# 提供选择菜单
echo "=== 选择操作 ==="
echo "1) 启动端口转发 (推荐)"
echo "2) 测试 NodePort 访问"
echo "3) 查看 Kibana 日志"
echo "4) 查看 Elasticsearch 状态"
echo "5) 退出"
echo ""

read -p "请选择操作 (1-5): " choice

case $choice in
    1)
        echo "启动 Kibana 端口转发..."
        echo "访问地址: http://localhost:5601"
        echo "按 Ctrl+C 停止端口转发"
        kubectl port-forward --address 0.0.0.0 -n kibana svc/kibana-service 5601:5601
        ;;
    2)
        echo "测试 NodePort 访问..."
        curl -I "http://$MINIKUBE_IP:30561" --connect-timeout 10 || echo "NodePort 访问失败，请使用端口转发"
        ;;
    3)
        echo "查看 Kibana 日志..."
        kubectl logs -n kibana deployment/kibana --tail=50
        ;;
    4)
        echo "查看 Elasticsearch 状态..."
        kubectl get pods -n elasticsearch
        kubectl get svc -n elasticsearch
        ;;
    5)
        echo "退出脚本"
        exit 0
        ;;
    *)
        echo "无效选择"
        exit 1
        ;;
esac