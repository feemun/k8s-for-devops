# Kubernetes / Minikube 资源分配参考指南

本文档用于指导在本地或服务器上使用 Minikube 时，根据宿主机资源合理分配 **CPU、内存、磁盘**，保证 Kubernetes 集群稳定运行，同时不影响宿主机性能。

---

## 1️⃣ 查看宿主机资源

### 1.1 CPU 核心数

```bash
lscpu
```
- 输出示例：
```
CPU(s):              8
Thread(s) per core:  2
Core(s) per socket:  4
```
- `CPU(s)` → 总逻辑核心数（含超线程）
- `Core(s) per socket` → 物理核心数
- **建议**：分配给 Minikube CPU ≤ 总核心数的一半

### 1.2 内存

```bash
free -h
```
- 输出示例：
```
              total        used        free      shared  buff/cache   available
Mem:           16G         4G         8G         512M         4G         11G
Swap:          2G          0B         2G
```
- `available` → 可用内存
- **建议**：分配给 Minikube ≤ 可用内存的一半

### 1.3 磁盘空间

```bash
df -h
```
- 输出示例：
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        500G  200G  275G  43% /
```
- `Avail` → 可用磁盘空间
- **建议**：分配给 Minikube ≤ 可用空间的 50-70%

---

## 2️⃣ 配置 Minikube 资源

### 2.1 启动时指定资源

```bash
minikube start --driver=kvm2 --cpus=4 --memory=8192 --disk-size=50g
```
- `--cpus` → CPU 核心数
- `--memory` → 内存（MB）
- `--disk-size` → 虚拟机磁盘空间（GB）

### 2.2 修改默认配置（便于下次启动）

```bash
minikube config set cpus 4
minikube config set memory 8192
minikube config set disk-size 50g
```
- 下次启动无需再指定参数：
```bash
minikube start --driver=kvm2
```

### 2.3 修改已存在 VM 资源

1. 停止 Minikube：
```bash
minikube stop
```
2. 重新启动并指定新资源：
```bash
minikube start --driver=kvm2 --cpus=6 --memory=16384 --disk-size=50g
```

> 对磁盘扩容，若现有 VM 不支持在线扩容，建议 `minikube delete` 重新创建。

---

## 3️⃣ 查看当前 Minikube 资源配置

```bash
minikube profile list
minikube config view
```
- 可以查看已分配 CPU、内存、磁盘大小

---

## 4️⃣ 资源分配建议示例

| 宿主机资源       | 推荐 Minikube 配置           |
|-----------------|-----------------------------|
| CPU: 8 核       | CPU: 4 核                  |
| 内存: 16 GB     | 内存: 8 GB                  |
| 可用磁盘: 275 GB| 磁盘: 50 GB                 |

> 建议保留宿主机至少一半的资源给系统和其他程序，避免卡顿。

---

## 5️⃣ 额外提示

- 使用 `minikube stop` 再启动可调整资源。
- 使用 `--iso-url=file://<path>` 可指定本地 ISO，便于离线启动。
- CPU/内存分配过高可能导致宿主机卡顿，过低则影响 Kubernetes 性能。
- 对磁盘，kvm2 驱动支持稀疏文件，可按需增长。