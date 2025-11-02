# KubePi 快速开始 🚀

## 一键部署（推荐）

```bash
# 进入目录
cd kubepi

# 一键部署（NodePort 方式，适合局域网访问）
./deploy.sh nodeport

# 查看状态
./deploy.sh status
```

## 手动部署

```bash
# 1. 部署到集群
kubectl apply -f kubepi-deploy.yaml

# 2. 等待启动
kubectl wait --for=condition=ready pod -l app=kubepi -n kubepi --timeout=300s

# 3. 配置 NodePort 访问
kubectl patch svc kubepi-service -n kubepi -p '{"spec":{"type":"NodePort","ports":[{"port":80,"targetPort":80,"nodePort":30080}]}}'
```

## 🌐 局域网访问

### 获取访问地址
```bash
# 获取节点 IP
kubectl get nodes -o wide

# 访问地址格式
http://<节点IP>:30080
```

### 示例访问地址
- `http://192.168.1.100:30080`
- `http://10.0.0.50:30080`

## 🔐 登录信息

- **用户名**: `admin`
- **密码**: `kubepi123` （首次登录后请修改）

## 📋 常用命令

```bash
# 查看状态
kubectl get all -n kubepi

# 查看日志
kubectl logs -f deployment/kubepi -n kubepi

# 重启服务
kubectl rollout restart deployment/kubepi -n kubepi

# 清理资源
./deploy.sh cleanup
# 或
kubectl delete -f kubepi-deploy.yaml
```

## 🛠️ 故障排查

```bash
# 检查 Pod 状态
kubectl describe pod -l app=kubepi -n kubepi

# 检查服务
kubectl get svc -n kubepi

# 端口转发（临时访问）
kubectl port-forward -n kubepi svc/kubepi-service 8080:80
# 然后访问 http://localhost:8080
```

---
💡 **提示**: 详细文档请查看 [README.md](README.md)