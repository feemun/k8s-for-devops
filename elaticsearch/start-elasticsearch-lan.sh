#!/bin/bash

# Elasticsearch 局域网访问启动脚本 (HTTPS版本)
# 用途：启动端口转发，使局域网中的其他机器能够访问 Elasticsearch HTTPS

echo "🚀 启动 Elasticsearch HTTPS 局域网访问..."
echo "📍 Minikube IP: 192.168.49.2"
echo "🔌 HTTPS端口: 30920 (映射到9200)"
echo "🔌 Transport端口: 30930 (映射到9300)"
echo "🔐 安全认证: 用户名 elastic, 密码 elastic123"

# 检查 Elasticsearch Pod 状态
echo "📊 检查 Elasticsearch Pod 状态..."
kubectl get pods -n elasticsearch

# 检查 Elasticsearch 服务状态
echo "🔍 检查 Elasticsearch 服务状态..."
kubectl get svc -n elasticsearch

echo ""
echo "🌐 HTTPS 外部访问方式："
echo "1. 直接访问 Minikube IP (HTTPS):"
echo "   - HTTPS API: https://192.168.49.2:30920"
echo "   - 认证: curl -k -u elastic:elastic123 https://192.168.49.2:30920"
echo ""
echo "2. 端口转发到本机 (推荐):"
echo "   - HTTPS: kubectl port-forward --address 0.0.0.0 -n elasticsearch svc/elasticsearch-service 9200:9200"
echo "   - 然后通过 https://[本机IP]:9200 访问"
echo "   - 测试: curl -k -u elastic:elastic123 https://[本机IP]:9200/_cluster/health"
echo ""

# 提供选择菜单
echo "请选择操作："
echo "1) 启动 HTTPS 端口转发"
echo "2) 测试 HTTPS 连接"
echo "3) 查看 Elasticsearch 日志"
echo "4) 退出"
echo ""

read -p "请输入选择 (1-4): " choice

case $choice in
    1)
        echo "🌐 启动 HTTPS 端口转发 (0.0.0.0:9200 -> Elasticsearch Service)..."
        echo "💡 局域网中的其他机器现在可以通过 https://[本机IP]:9200 访问 Elasticsearch"
        echo "🔐 认证信息: 用户名 elastic, 密码 elastic123"
        echo "⚠️  按 Ctrl+C 停止端口转发"
        echo ""
        
        # 启动端口转发（前台运行）
        kubectl port-forward --address 0.0.0.0 -n elasticsearch svc/elasticsearch-service 9200:9200
        ;;
    2)
        echo "🔍 测试 HTTPS 连接..."
        LOCAL_IP=$(hostname -I | awk '{print $1}')
        echo "本机IP: $LOCAL_IP"
        echo "测试命令: curl -k -u elastic:elastic123 https://$LOCAL_IP:9200/_cluster/health"
        echo ""
        curl -k -u elastic:elastic123 https://$LOCAL_IP:9200/_cluster/health
        ;;
    3)
        echo "📋 查看 Elasticsearch 日志..."
        POD_NAME=$(kubectl get pods -n elasticsearch -l app=elasticsearch -o jsonpath='{.items[0].metadata.name}')
        kubectl logs $POD_NAME -n elasticsearch --tail=50
        ;;
    4)
        echo "👋 退出"
        exit 0
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac