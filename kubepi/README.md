# KubePi Kubernetes 部署使用文档

## 📖 简介

KubePi 是一个现代化的 Kubernetes 管理平台，提供直观的 Web 界面来管理 Kubernetes 集群资源。

## 🚀 快速部署

### 1. 部署到 Kubernetes 集群

```bash
# 克隆或下载配置文件
cd /path/to/kubepi

# 部署所有资源
kubectl apply -f kubepi-deploy.yaml
```

### 2. 验证部署状态

```bash
# 检查所有资源状态
kubectl get all -n kubepi

# 检查 Pod 状态
kubectl get pods -n kubepi

# 查看 Pod 日志
kubectl logs -f deployment/kubepi -n kubepi
```

### 3. 等待服务启动

```bash
# 等待 Pod 就绪
kubectl wait --for=condition=ready pod -l app=kubepi -n kubepi --timeout=300s
```

## 🌐 访问配置

### 方式一：NodePort 访问（推荐用于局域网访问）

1. **修改 Service 类型为 NodePort**：

```bash
# 编辑 Service
kubectl edit svc kubepi-service -n kubepi
```

将 `type: ClusterIP` 改为 `type: NodePort`，或者直接应用以下配置：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kubepi-service
  namespace: kubepi
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080  # 可选：指定端口，范围 30000-32767
    protocol: TCP
    name: http
  selector:
    app: kubepi
```

2. **获取访问地址**：

```bash
# 获取 NodePort
kubectl get svc kubepi-service -n kubepi

# 获取节点 IP
kubectl get nodes -o wide
```

3. **局域网访问**：
   - 访问地址：`http://<任意节点IP>:<NodePort>`
   - 例如：`http://192.168.1.100:30080`

### 方式二：LoadBalancer 访问（如果集群支持）

```bash
# 修改 Service 类型
kubectl patch svc kubepi-service -n kubepi -p '{"spec":{"type":"LoadBalancer"}}'

# 获取外部 IP
kubectl get svc kubepi-service -n kubepi
```

### 方式三：Ingress 访问（推荐用于生产环境）

1. **确保集群有 Ingress Controller**：

```bash
# 检查 Ingress Controller
kubectl get pods -n ingress-nginx
# 或
kubectl get pods -n kube-system | grep ingress
```

2. **修改 Ingress 配置**：

编辑 `kubepi-deploy.yaml` 中的 Ingress 部分：

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubepi-ingress
  namespace: kubepi
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: kubepi.local  # 改为你的域名或使用 IP
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kubepi-service
            port:
              number: 80
```

3. **配置本地 DNS**（如果使用域名）：

```bash
# 在局域网机器的 /etc/hosts 文件中添加
echo "<Ingress-Controller-IP> kubepi.local" >> /etc/hosts
```

### 方式四：端口转发（临时访问）

```bash
# 端口转发到本地
kubectl port-forward -n kubepi svc/kubepi-service 8080:80

# 访问地址：http://localhost:8080
```

## 🔧 配置调整

### 存储配置

根据你的集群存储类调整 PVC：

```bash
# 查看可用存储类
kubectl get storageclass

# 编辑 PVC
kubectl edit pvc kubepi-data-pvc -n kubepi
```

### 资源配置

根据集群资源调整 Deployment 的资源限制：

```yaml
resources:
  requests:
    memory: "512Mi"    # 增加内存请求
    cpu: "200m"        # 增加 CPU 请求
  limits:
    memory: "1Gi"      # 增加内存限制
    cpu: "1000m"       # 增加 CPU 限制
```

## 🔐 首次登录

1. **获取默认管理员密码**：

```bash
# 查看 Pod 日志获取初始密码
kubectl logs deployment/kubepi -n kubepi | grep -i password
```

2. **登录信息**：
   - 默认用户名：`admin`
   - 默认密码：查看日志或 `kubepi123`（具体以日志为准）

3. **首次登录后请立即修改密码**

## 📱 局域网访问步骤总结

### 快速配置 NodePort 访问

1. **应用 NodePort 配置**：

```bash
# 创建 NodePort Service 配置文件
cat > kubepi-nodeport.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: kubepi-nodeport
  namespace: kubepi
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
  selector:
    app: kubepi
EOF

# 应用配置
kubectl apply -f kubepi-nodeport.yaml
```

2. **获取访问信息**：

```bash
# 获取节点 IP 和端口
kubectl get nodes -o wide
kubectl get svc -n kubepi
```

3. **局域网访问**：
   - 在局域网任意机器浏览器中访问：`http://<节点IP>:30080`
   - 例如：`http://192.168.1.100:30080`

## 🛠️ 故障排查

### 常见问题

1. **Pod 无法启动**：
```bash
kubectl describe pod -l app=kubepi -n kubepi
kubectl logs -f deployment/kubepi -n kubepi
```

2. **存储问题**：
```bash
kubectl describe pvc kubepi-data-pvc -n kubepi
```

3. **网络访问问题**：
```bash
# 检查 Service
kubectl get svc -n kubepi
kubectl describe svc kubepi-service -n kubepi

# 检查防火墙（在节点上执行）
sudo ufw status
sudo firewall-cmd --list-ports
```

### 清理资源

```bash
# 删除所有 KubePi 资源
kubectl delete -f kubepi-deploy.yaml

# 或者删除整个命名空间
kubectl delete namespace kubepi
```

## 📋 维护操作

### 更新 KubePi

```bash
# 更新镜像
kubectl set image deployment/kubepi kubepi=kubepi/kubepi:latest -n kubepi

# 重启 Deployment
kubectl rollout restart deployment/kubepi -n kubepi
```

### 备份数据

```bash
# 备份数据库文件
kubectl exec -n kubepi deployment/kubepi -- tar -czf /tmp/kubepi-backup.tar.gz /opt/kubepi/db
kubectl cp kubepi/<pod-name>:/tmp/kubepi-backup.tar.gz ./kubepi-backup.tar.gz
```

## 🔗 相关链接

- [KubePi 官方文档](https://kubepi.org/)
- [KubePi GitHub](https://github.com/KubeOperator/kubepi)
- [Kubernetes 官方文档](https://kubernetes.io/docs/)

---

**注意**：请根据你的实际网络环境和安全要求调整配置。在生产环境中，建议使用 HTTPS 和适当的认证机制。