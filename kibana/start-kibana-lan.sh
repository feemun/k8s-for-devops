#!/bin/bash

# Kibana 9.2.0 局域网访问启动脚本 (支持 HTTPS Elasticsearch)
# 与 Elasticsearch 9.2.0 HTTPS 集成

echo "=== Kibana 9.2.0 局域网访问脚本 (HTTPS 支持) ==="
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

# 获取本机局域网IP
LOCAL_IP=$(ip route get 8.8.8.8 | awk '{print $7; exit}')
MINIKUBE_IP=$(minikube ip)
echo "3. 本机局域网IP: $LOCAL_IP"
echo "4. Minikube IP: $MINIKUBE_IP"
echo ""

# 显示访问信息
echo "=== Kibana 访问信息 ==="
echo "局域网访问 (推荐):"
echo "  URL: http://$LOCAL_IP:5601"
echo ""
echo "NodePort 访问:"
echo "  URL: http://$MINIKUBE_IP:30561"
echo ""

# 检查 Elasticsearch HTTPS 连接
echo "5. 检查 Elasticsearch HTTPS 连接状态..."
kubectl get pods -n elasticsearch
echo ""

# 显示 Elasticsearch HTTPS 访问信息
echo "=== Elasticsearch HTTPS 访问信息 ==="
echo "局域网 HTTPS 访问:"
echo "  URL: https://$LOCAL_IP:9200"
echo "  用户名: elastic"
echo "  密码: elastic123"
echo "  测试命令: curl -k -u elastic:elastic123 https://$LOCAL_IP:9200/_cluster/health?pretty"
echo ""

# 提供选择菜单
echo "=== 选择操作 ==="
echo "1) 启动 Kibana 端口转发 (推荐)"
echo "2) 启动 Elasticsearch HTTPS 端口转发"
echo "3) 启动所有服务端口转发"
echo "4) 测试 Elasticsearch HTTPS 连接"
echo "5) 查看 Kibana 日志"
echo "6) 查看 Elasticsearch 日志"
echo "7) 退出"
echo ""

read -p "请选择操作 (1-7): " choice

case $choice in
    1)
        echo "启动 Kibana 端口转发..."
        echo "访问地址: http://$LOCAL_IP:5601"
        kubectl port-forward --address=0.0.0.0 -n kibana svc/kibana-nodeport 5601:5601
        ;;
    2)
        echo "启动 Elasticsearch HTTPS 端口转发..."
        echo "访问地址: https://$LOCAL_IP:9200"
        echo "用户名: elastic, 密码: elastic123"
        kubectl port-forward --address=0.0.0.0 -n elasticsearch svc/elasticsearch-nodeport 9200:9200
        ;;
    3)
        echo "启动所有服务端口转发..."
        echo "Kibana: http://$LOCAL_IP:5601"
        echo "Elasticsearch: https://$LOCAL_IP:9200 (用户名: elastic, 密码: elastic123)"
        echo ""
        echo "在新终端中运行以下命令启动 Elasticsearch 端口转发:"
        echo "kubectl port-forward --address=0.0.0.0 -n elasticsearch svc/elasticsearch-nodeport 9200:9200"
        echo ""
        echo "现在启动 Kibana 端口转发..."
        kubectl port-forward --address=0.0.0.0 -n kibana svc/kibana-nodeport 5601:5601
        ;;
    4)
        echo "测试 Elasticsearch HTTPS 连接..."
        curl -k -u elastic:elastic123 https://$LOCAL_IP:9200/_cluster/health?pretty
        ;;
    5)
        echo "查看 Kibana 日志..."
        kubectl logs -n kibana -l app=kibana --tail=50
        ;;
    6)
        echo "查看 Elasticsearch 日志..."
        kubectl logs -n elasticsearch -l app=elasticsearch --tail=50
        ;;
    7)
        echo "退出脚本"
        exit 0
        ;;
    *)
        echo "无效选择，请重新运行脚本"
        exit 1
        ;;
esac