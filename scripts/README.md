# 服务部署与端口转发使用说明

本文档描述如何在 Kubernetes（Minikube）中部署服务（如 MySQL、Elasticsearch）并自动将 NodePort 暴露到局域网，供外部访问。

---

## ✅ 前提条件

- 已安装 `kubectl` 和 `minikube`
- 已启动 Minikube 集群
- 已克隆本项目到本地

---

## ✅ 快速启动一个服务（以 MySQL 为例）

### 1. 部署服务

```bash
kubectl apply -f mysql/mysql-deploy.yaml
```

### 2. 启动端口转发（局域网可访问）

```bash
chmod +x scripts/*.sh
./scripts/start-port-forwards.sh
```

### 3. 验证转发是否成功

```bash
tail -f scripts/logs/mysql-nodeport.log
```

你应该看到类似输出：
```
Forwarding from 0.0.0.0:30306 -> 3306
```

### 4. 从局域网访问 MySQL

假设你部署机器的 IP 是 `192.168.1.100`，则局域网内其他机器可通过以下方式连接：

```bash
mysql -h 192.168.1.100 -P 30306 -u testuser -puserpass testdb
```

---

## ✅ 添加新服务（如 Redis、Elasticsearch）

### 1. 确保你的服务 YAML 中定义了 NodePort 类型的 Service

例如：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-nodeport
  namespace: default
spec:
  type: NodePort
  ports:
  - port: 6379
    targetPort: 6379
    nodePort: 30379
  selector:
    app: redis
```

### 2. 在 `scripts/services.txt` 中添加一行

```txt
redis-nodeport default 30379 6379
```

### 3. 启动转发

```bash
./scripts/start-port-forwards.sh
```

---

## ✅ 常用命令

| 操作 | 命令 |
|------|------|
| 启动所有端口转发 | `./scripts/start-port-forwards.sh` |
| 停止所有端口转发 | `./scripts/stop-port-forwards.sh` |
| 查看某服务日志 | `tail -f scripts/logs/<服务名>.log` |
| 查看转发是否运行 | `pgrep -f "kubectl.*port-forward"` |

---

## ✅ 注意事项

- 每个服务必须有一个 **NodePort 类型的 Service**
- `services.txt` 中每行格式为：`服务名 命名空间 本地端口 目标端口`
- 日志文件保存在 `scripts/logs/` 目录下
- 端口转发只在后台运行，重启机器后需重新执行脚本

---

## ✅ 示例：部署并启动 Elasticsearch

```bash
kubectl apply -f elasticsearch/elasticsearch-deploy.yaml
./scripts/start-port-forwards.sh
curl http://<你的IP>:30200
```

---

如需添加更多服务，只需重复上述步骤即可。