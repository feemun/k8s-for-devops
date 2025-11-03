#!/bin/bash

# Elasticsearch 局域网访问启动脚本
# 用途：启动端口转发，使局域网中的其他机器能够访问 Elasticsearch

echo "🚀 启动 Elasticsearch 局域网访问..."
echo "📍 Minikube IP: 192.168.49.2"
echo "🔌 HTTP端口: 30920 (映射到9200)"
echo "🔌 Transport端口: 30930 (映射到9300)"

# 检查 Elasticsearch Pod 状态
echo "📊 检查 Elasticsearch Pod 状态..."
kubectl get pods -n elasticsearch

# 检查 Elasticsearch 服务状态
echo "🔍 检查 Elasticsearch 服务状态..."
kubectl get svc -n elasticsearch

echo ""
echo "🌐 外部访问方式："
echo "1. 直接访问 Minikube IP:"
echo "   - HTTP API: http://192.168.49.2:30920"
echo "   - Transport: 192.168.49.2:30930"
echo ""
echo "2. 端口转发到本机 (推荐):"
echo "   - HTTP: kubectl port-forward --address 0.0.0.0 -n elasticsearch svc/elasticsearch-service 9200:9200"
echo "   - 然后通过 http://[本机IP]:9200 访问"
echo ""

# 提供选择
read -p "是否启动端口转发到本机所有接口? (y/n): " choice
if [[ $choice == "y" || $choice == "Y" ]]; then
    echo "🌐 启动端口转发 (0.0.0.0:9200 -> Elasticsearch Service)..."
    echo "💡 局域网中的其他机器现在可以通过 [本机IP]:9200 访问 Elasticsearch"
    echo "⚠️  按 Ctrl+C 停止端口转发"
    echo ""
    
    # 启动端口转发（前台运行）
    kubectl port-forward --address 0.0.0.0 -n elasticsearch svc/elasticsearch-service 9200:9200
else
    echo "✅ 可以直接通过 Minikube IP 访问: http://192.168.49.2:30920"
fi