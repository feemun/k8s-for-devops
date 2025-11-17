# Minikube + KVM2 完整安装指南（Debian/Ubuntu）

本文档指导你在 Debian/Ubuntu 系统上，使用 kvm2 驱动安装 Minikube，实现 **完全不依赖 Docker** 的稳定 Kubernetes 集群环境。

---

## 0. 前提条件

- 系统：Debian 12 / Ubuntu 22.04+
- 用户：普通用户 `k8suser`，并能使用 root
- CPU 支持虚拟化（Intel VT-x 或 AMD-V）
- 至少 16GB 内存（推荐）
- 至少 4 核 CPU（推荐）

---

## 1. 安装 KVM / libvirt

切换到 root 用户：
```bash
su -
```

安装 KVM 及相关组件：
```bash
apt update
apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
```

验证 KVM 是否启用：
```bash
lsmod | grep kvm
egrep -c '(vmx|svm)' /proc/cpuinfo
```

- 输出 >0 表示 CPU 支持虚拟化
- lsmod 显示 kvm_intel 或 kvm_amd 已加载

---

## 2. 将普通用户加入 libvirt / kvm 组

```bash
usermod -aG libvirt k8suser
usermod -aG kvm k8suser
```

> 修改生效后，`k8suser` 需要退出并重新登录。

---

## 3. 安装 Minikube kvm2 驱动

手动下载安装，避免自动下载提示：
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2
chmod +x docker-machine-driver-kvm2
sudo mv docker-machine-driver-kvm2 /usr/local/bin/
```

验证安装：
```bash
docker-machine-driver-kvm2 version
```
> 注意：名字里有 docker，但完全不依赖 Docker。

---

## 4. 修正 root PATH（避免命令找不到）

```bash
echo 'export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin' >> /root/.bashrc
source /root/.bashrc
```

验证 PATH：
```bash
echo $PATH
```
> 应包含 `/sbin:/usr/sbin:/usr/local/sbin`

---

## 5. 启动 Minikube（kvm2 驱动）

以普通用户 `k8suser` 启动：
```bash
minikube start --driver=kvm2 \
  --cpus=4 \
  --memory=8192 \
  --disk-size=30g
```

说明：
- `--driver=kvm2` → 使用 KVM 虚拟机
- `--cpus` / `--memory` → 根据机器调整
- `--disk-size` → 虚拟机硬盘大小

---

## 6. 验证集群状态

```bash
kubectl get nodes
kubectl cluster-info
```
> 确认节点就绪，API Server 正常运行。

---

## 7. 可选：导入已有镜像

如果之前使用 Docker driver 拉过镜像：
```bash
minikube image load myimage:latest
```

---

## 完成效果

- Minikube 完全不依赖 Docker
- Namespace 删除卡住概率极低
- PVC / PV / CRD 操作稳定
- 可随意安装 Helm chart / Operator / Ingress

---

文档到此结束。