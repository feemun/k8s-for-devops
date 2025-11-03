# Elasticsearch 9.2.0 HTTPS 使用指南

## 📋 概述

本文档介绍如何使用已配置 HTTPS 安全访问的 Elasticsearch 9.2.0 集群。该集群部署在 Kubernetes 环境中，启用了 X-Pack Security 功能。

## 🔐 认证信息

### 管理员账户
- **用户名**: `elastic`
- **密码**: `elastic123`
- **权限**: 超级用户，拥有所有权限

### 服务账户
- **用户名**: `kibana_system`
- **密码**: `kibana123`
- **用途**: Kibana 服务专用账户

## 🌐 访问地址

### HTTPS API 访问
- **URL**: `https://192.168.1.102:9200`
- **证书**: 自签名证书（需要 `-k` 参数忽略证书验证）

### 集群内部访问
- **URL**: `https://elasticsearch-service.elasticsearch.svc.cluster.local:9200`

## 🚀 快速开始

### 1. 启动服务
```bash
# 使用启动脚本
cd /home/k8suser/k8s-for-devops/elaticsearch
./start-elasticsearch-lan.sh

# 选择选项 1: 启动 HTTPS 端口转发
```

### 2. 验证连接
```bash
# 检查集群健康状态
curl -k -u elastic:elastic123 https://192.168.1.102:9200/_cluster/health?pretty

# 查看集群信息
curl -k -u elastic:elastic123 https://192.168.1.102:9200/
```

## 📊 常用 API 操作

### 集群管理

#### 查看集群状态
```bash
# 集群健康状态
curl -k -u elastic:elastic123 https://192.168.1.102:9200/_cluster/health?pretty

# 集群统计信息
curl -k -u elastic:elastic123 https://192.168.1.102:9200/_cluster/stats?pretty

# 节点信息
curl -k -u elastic:elastic123 https://192.168.1.102:9200/_nodes?pretty
```

#### 查看索引
```bash
# 列出所有索引
curl -k -u elastic:elastic123 https://192.168.1.102:9200/_cat/indices?v

# 查看特定索引信息
curl -k -u elastic:elastic123 https://192.168.1.102:9200/your-index-name
```

### 数据操作

#### 创建索引
```bash
# 创建索引
curl -k -u elastic:elastic123 -X PUT https://192.168.1.102:9200/my-index \
  -H "Content-Type: application/json" \
  -d '{
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    }
  }'
```

#### 添加文档
```bash
# 添加文档
curl -k -u elastic:elastic123 -X POST https://192.168.1.102:9200/my-index/_doc \
  -H "Content-Type: application/json" \
  -d '{
    "title": "示例文档",
    "content": "这是一个测试文档",
    "timestamp": "2024-01-01T00:00:00Z"
  }'
```

#### 搜索文档
```bash
# 搜索所有文档
curl -k -u elastic:elastic123 https://192.168.1.102:9200/my-index/_search?pretty

# 条件搜索
curl -k -u elastic:elastic123 -X GET https://192.168.1.102:9200/my-index/_search \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "match": {
        "title": "示例"
      }
    }
  }'
```

## 🔧 安全配置

### SSL/TLS 设置
- **协议**: TLS 1.2+
- **证书类型**: 自签名证书 (P12 格式)
- **验证模式**: 客户端需要使用 `-k` 参数跳过证书验证

### 用户管理
```bash
# 查看所有用户
curl -k -u elastic:elastic123 https://192.168.1.102:9200/_security/user

# 创建新用户
curl -k -u elastic:elastic123 -X POST https://192.168.1.102:9200/_security/user/new_user \
  -H "Content-Type: application/json" \
  -d '{
    "password": "new_password",
    "roles": ["kibana_user"],
    "full_name": "New User"
  }'

# 修改用户密码
curl -k -u elastic:elastic123 -X PUT https://192.168.1.102:9200/_security/user/username/_password \
  -H "Content-Type: application/json" \
  -d '{
    "password": "new_password"
  }'
```

## 🛠️ 故障排除

### 常见问题

#### 1. 连接被拒绝
```bash
# 检查服务状态
kubectl get pods -n elasticsearch
kubectl get svc -n elasticsearch

# 检查端口转发
ps aux | grep port-forward
```

#### 2. 认证失败
```bash
# 验证用户名密码
curl -k -u elastic:elastic123 https://192.168.1.102:9200/_security/_authenticate

# 重置 elastic 用户密码
kubectl exec -n elasticsearch deployment/elasticsearch -- \
  bin/elasticsearch-reset-password -u elastic
```

#### 3. SSL 证书错误
```bash
# 使用 -k 参数忽略证书验证
curl -k -u elastic:elastic123 https://192.168.1.102:9200/

# 或者下载证书进行验证
kubectl exec -n elasticsearch deployment/elasticsearch -- \
  cat config/certs/http.p12 > elasticsearch-cert.p12
```

### 日志查看
```bash
# 查看 Elasticsearch 日志
kubectl logs -n elasticsearch -l app=elasticsearch --tail=100

# 实时查看日志
kubectl logs -n elasticsearch -l app=elasticsearch -f
```

## 📈 性能监控

### 集群监控
```bash
# 查看集群性能统计
curl -k -u elastic:elastic123 https://192.168.1.102:9200/_cluster/stats?pretty

# 查看节点统计
curl -k -u elastic:elastic123 https://192.168.1.102:9200/_nodes/stats?pretty

# 查看索引统计
curl -k -u elastic:elastic123 https://192.168.1.102:9200/_stats?pretty
```

### 系统资源
```bash
# 查看 JVM 堆内存使用
curl -k -u elastic:elastic123 https://192.168.1.102:9200/_nodes/stats/jvm?pretty

# 查看文件系统使用情况
curl -k -u elastic:elastic123 https://192.168.1.102:9200/_nodes/stats/fs?pretty
```

## 🔗 相关链接

- [Elasticsearch 官方文档](https://www.elastic.co/guide/en/elasticsearch/reference/current/)
- [X-Pack Security 配置](https://www.elastic.co/guide/en/elasticsearch/reference/current/security-settings.html)
- [REST API 参考](https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html)

## 📞 技术支持

如遇到问题，请检查：
1. Kubernetes 集群状态
2. Pod 运行状态和日志
3. 网络连接和端口转发
4. 认证信息是否正确

---

*文档版本: 1.0*  
*更新时间: 2024-01-01*  
*适用版本: Elasticsearch 9.2.0*