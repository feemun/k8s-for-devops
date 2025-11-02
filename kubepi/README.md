# KubePi 部署和局域网访问指南

## 📖 概述

KubePi 是一个现代化的 Kubernetes 管理界面，本项目提供了在 minikube 环境中部署 KubePi 并实现局域网访问的完整解决方案。

## 📁 文件说明

- `kubepi-deploy.yaml` - KubePi 的 Kubernetes 部署配置文件（已配置 NodePort）
- `start-kubepi-lan.sh` - 局域网访问自动化启动脚本
- `README.md` - 本说明文件

## 🚀 快速开始

### 1. 部署 KubePi

```bash
# 应用部署配置
kubectl apply -f kubepi-deploy.yaml

# 检查部署状态
kubectl get pods -n kubepi
```

### 2. 启动局域网访问

```bash
# 使用自动化脚本（推荐）
./start-kubepi-lan.sh

# 或手动启动端口转发
kubectl port-forward --address 0.0.0.0 -n kubepi svc/kubepi-service 30888:80
```

### 3. 访问 KubePi

- **局域网访问**: `http://你的局域网IP:30888`
- **本机访问**: `http://localhost:30888` 或 `http://127.0.0.1:30888`

## 🔐 默认登录信息

- **用户名**: `admin`
- **密码**: `kubepi`

## ⚙️ 部署详情

### 服务配置

- **命名空间**: `kubepi`
- **服务类型**: `NodePort`
- **内部端口**: `80`
- **NodePort**: `30888`
- **镜像**: `1panel/kubepi:latest`

### 资源配置

- **CPU 限制**: 500m
- **内存限制**: 512Mi
- **存储**: 1Gi PVC (ReadWriteOnce)

## 🌐 网络访问说明

### minikube 网络限制

由于 minikube 运行在虚拟机中，其 NodePort 服务默认只能通过 minikube 的内部 IP 访问，局域网中的其他机器无法直接访问。

### 解决方案

本项目提供了两种解决方案：

#### 方案一：使用自动化脚本（推荐）

```bash
./start-kubepi-lan.sh
```

脚本功能：
- 自动检测局域网 IP
- 验证 KubePi 运行状态
- 启动端口转发到所有网络接口
- 提供访问地址信息

#### 方案二：手动端口转发

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