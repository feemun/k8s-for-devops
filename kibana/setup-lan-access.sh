#!/bin/bash

echo "设置Elasticsearch和Kibana的局域网访问..."

# 获取minikube IP
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"

# 获取本机局域网IP
LOCAL_IP=$(ip route get 8.8.8.8 | awk '{print $7; exit}')
echo "本机局域网IP: $LOCAL_IP"

echo ""
echo "=== 当前可用的访问方式 ==="
echo ""
echo "1. 通过minikube IP访问（仅本机）:"
echo "   Elasticsearch: http://$MINIKUBE_IP:30920"
echo "   Kibana: http://$MINIKUBE_IP:30561"
echo ""
echo "2. 通过本机IP访问（局域网内所有设备）:"
echo "   需要设置端口转发..."
echo ""

# 检查是否有端口转发在运行
if pgrep -f "port-forward" > /dev/null; then
    echo "检测到正在运行的端口转发进程"
    echo "请先停止现有的端口转发，然后运行以下命令："
else
    echo "建议的端口转发命令："
fi

echo ""
echo "# 转发Elasticsearch HTTP API (9200 -> 30920)"
echo "kubectl port-forward --address=0.0.0.0 -n elasticsearch svc/elasticsearch-nodeport 9200:9200 &"
echo ""
echo "# 转发Elasticsearch传输层 (9300 -> 30930)" 
echo "kubectl port-forward --address=0.0.0.0 -n elasticsearch svc/elasticsearch-nodeport 9300:9300 &"
echo ""
echo "# 转发Kibana (5601 -> 30561)"
echo "kubectl port-forward --address=0.0.0.0 -n kibana svc/kibana-nodeport 5601:5601 &"
echo ""
echo "设置完成后，局域网设备可以通过以下地址访问："
echo "   Elasticsearch: http://$LOCAL_IP:9200"
echo "   Kibana: http://$LOCAL_IP:5601"