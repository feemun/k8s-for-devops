#!/bin/bash
# 用途：把宿主机端口映射到集群内，支持 Service / Deployment / Pod / NodePort

# 方案一：转发到 Service（推荐）
# 命令：kubectl port-forward --address 0.0.0.0 service/<service-name> <本机端口>:<Service.port> -n <namespace>
# 示例：kubectl port-forward --address 0.0.0.0 service/mysql-service 13306:3306 -n mysql
# 对应关系：Service.port → mysql/mysql-deploy.yaml:164；targetPort → mysql/mysql-deploy.yaml:165；containerPort → mysql/mysql-deploy.yaml:97；MySQL监听 → mysql/mysql-deploy.yaml:54

# 方案二：转发到 Deployment（不依赖 Service）
# 命令：kubectl port-forward --address 0.0.0.0 deploy/<deploy-name> <本机端口>:<容器端口> -n <namespace>
# 示例：kubectl port-forward --address 0.0.0.0 deploy/mysql 13306:3306 -n mysql

# 方案三：转发到 Pod（指定具体 Pod）
# 命令：kubectl port-forward --address 0.0.0.0 pod/<pod-name> <本机端口>:<容器端口> -n <namespace>
# 示例：kubectl port-forward --address 0.0.0.0 pod/mysql-xxxxxxxx 13306:3306 -n mysql

# 说明：
# - 左侧是“本机端口”，他机连接你的宿主机时用这个端口
# - 右侧取决于目标：Service 用 Service.port；Pod/Deployment 用容器实际端口
# - --address 0.0.0.0 表示允许其他机器访问；改为 127.0.0.1 则仅本机
# - 确保本机端口未被占用，且防火墙放行该端口

# 默认执行：转发到 Service 的 3306
kubectl port-forward --address 0.0.0.0 service/mysql-service 13306:3306 -n mysql &