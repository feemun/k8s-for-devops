# Redis 使用指南

## 概述

本文档介绍如何使用已部署的 Redis 服务，该服务运行在 Kubernetes 集群中，支持局域网访问。

## 服务信息

### 访问地址
- **集群内访问**: `redis-service.redis-service.svc.cluster.local:6379`
- **局域网访问**: `192.168.49.2:30379` (NodePort)
- **外网访问**: `192.168.1.102:16379` (端口转发)
- **命名空间**: `redis-service`

### 服务配置
- **Redis 版本**: 7.2.0-alpine
- **端口**: 6379
- **持久化**: 启用 AOF 持久化
- **内存限制**: 512MB
- **存储**: 5GB PersistentVolume

## 快速开始

### 1. 启动服务

#### 局域网访问
使用提供的启动脚本：

```bash
cd /home/k8suser/k8s-for-devops/redis
./start-redis-lan.sh
```

#### 外网访问
使用外网访问启动脚本：

```bash
cd /home/k8suser/k8s-for-devops/redis
./start-redis-external.sh
```

### 2. 检查服务状态

```bash
# 查看 Pod 状态
kubectl get pods -n redis-service

# 查看服务状态
kubectl get svc -n redis-service

# 查看详细信息
kubectl describe deployment redis -n redis-service
```

### 3. 连接测试

#### 集群内连接测试
```bash
kubectl exec -n redis-service deployment/redis -- redis-cli ping
```

#### 外网连接测试
```bash
# 使用 redis-cli (需要安装 redis-tools)
redis-cli -h 192.168.1.102 -p 16379 ping

# 使用 telnet 测试连接
telnet 192.168.1.102 16379

# 使用 nc 测试连接
echo "PING" | nc 192.168.1.102 16379
```

## 常用操作

### 基本 Redis 命令

#### 字符串操作
```bash
# 设置键值
redis-cli -h 192.168.49.2 -p 30379 set mykey "Hello Redis"

# 获取值
redis-cli -h 192.168.49.2 -p 30379 get mykey

# 设置过期时间 (秒)
redis-cli -h 192.168.49.2 -p 30379 setex tempkey 60 "temporary value"
```

#### 列表操作
```bash
# 左侧推入
redis-cli -h 192.168.49.2 -p 30379 lpush mylist "item1" "item2"

# 右侧推入
redis-cli -h 192.168.49.2 -p 30379 rpush mylist "item3"

# 获取列表
redis-cli -h 192.168.49.2 -p 30379 lrange mylist 0 -1
```

#### 哈希操作
```bash
# 设置哈希字段
redis-cli -h 192.168.49.2 -p 30379 hset user:1 name "John" age 30

# 获取哈希字段
redis-cli -h 192.168.49.2 -p 30379 hget user:1 name

# 获取所有哈希字段
redis-cli -h 192.168.49.2 -p 30379 hgetall user:1
```

#### 集合操作
```bash
# 添加成员
redis-cli -h 192.168.49.2 -p 30379 sadd myset "member1" "member2"

# 获取所有成员
redis-cli -h 192.168.49.2 -p 30379 smembers myset

# 检查成员是否存在
redis-cli -h 192.168.49.2 -p 30379 sismember myset "member1"
```

### 管理命令

#### 信息查看
```bash
# 查看 Redis 信息
redis-cli -h 192.168.49.2 -p 30379 info

# 查看内存使用
redis-cli -h 192.168.49.2 -p 30379 info memory

# 查看所有键
redis-cli -h 192.168.49.2 -p 30379 keys "*"

# 查看数据库大小
redis-cli -h 192.168.49.2 -p 30379 dbsize
```

#### 性能监控
```bash
# 实时监控命令
redis-cli -h 192.168.49.2 -p 30379 monitor

# 查看慢查询日志
redis-cli -h 192.168.49.2 -p 30379 slowlog get 10

# 查看客户端连接
redis-cli -h 192.168.49.2 -p 30379 client list
```

## 应用程序集成

### Python 示例

```python
import redis

# 连接 Redis
r = redis.Redis(host='192.168.49.2', port=30379, decode_responses=True)

# 基本操作
r.set('key', 'value')
value = r.get('key')
print(f"Value: {value}")

# 列表操作
r.lpush('mylist', 'item1', 'item2')
items = r.lrange('mylist', 0, -1)
print(f"List items: {items}")
```

### Node.js 示例

```javascript
const redis = require('redis');

// 创建客户端
const client = redis.createClient({
    host: '192.168.49.2',
    port: 30379
});

// 连接
client.on('connect', () => {
    console.log('Connected to Redis');
});

// 基本操作
client.set('key', 'value', (err, reply) => {
    console.log(reply);
});

client.get('key', (err, reply) => {
    console.log(reply);
});
```

### Java 示例

```java
import redis.clients.jedis.Jedis;

public class RedisExample {
    public static void main(String[] args) {
        // 连接 Redis
        Jedis jedis = new Jedis("192.168.49.2", 30379);
        
        // 基本操作
        jedis.set("key", "value");
        String value = jedis.get("key");
        System.out.println("Value: " + value);
        
        // 关闭连接
        jedis.close();
    }
}
```

## 数据持久化

### AOF 持久化
Redis 配置了 AOF (Append Only File) 持久化：
- **文件名**: `appendonly.aof`
- **同步策略**: `everysec` (每秒同步)
- **存储位置**: `/data` (容器内)

### 备份和恢复

#### 手动备份
```bash
# 执行 BGSAVE 命令
kubectl exec -n redis-service deployment/redis -- redis-cli bgsave

# 复制数据文件
kubectl cp redis-service/$(kubectl get pod -n redis-service -l app=redis -o jsonpath='{.items[0].metadata.name}'):/data ./redis-backup
```

#### 数据恢复
```bash
# 停止 Redis 服务
kubectl scale deployment redis -n redis-service --replicas=0

# 恢复数据文件
kubectl cp ./redis-backup redis-service/$(kubectl get pod -n redis-service -l app=redis -o jsonpath='{.items[0].metadata.name}'):/data

# 重启服务
kubectl scale deployment redis -n redis-service --replicas=1
```

## 安全配置

### 网络安全
- 使用 NetworkPolicy 控制网络访问
- 仅允许必要的端口访问
- 建议在生产环境中启用密码认证

### 密码认证 (可选)
如需启用密码认证，修改 ConfigMap：

```bash
kubectl edit configmap redis-config -n redis-service
```

取消注释并设置密码：
```
requirepass your_secure_password
```

然后重启 Redis：
```bash
kubectl rollout restart deployment redis -n redis-service
```

## 性能优化

### 内存优化
- 当前内存限制：512MB
- 内存策略：`allkeys-lru` (最近最少使用)
- 监控内存使用情况

### 连接优化
- 默认超时：0 (无超时)
- TCP keepalive：300 秒
- 最大客户端连接数：默认 10000

## 故障排除

### 常见问题

#### 1. Pod 无法启动
```bash
# 查看 Pod 状态
kubectl describe pod -n redis-service -l app=redis

# 查看日志
kubectl logs -n redis-service -l app=redis
```

#### 2. 连接被拒绝
- 检查 NodePort 服务状态
- 确认防火墙设置
- 验证网络策略配置

#### 3. 数据丢失
- 检查 PersistentVolume 状态
- 验证 AOF 文件完整性
- 查看 Redis 日志

### 日志查看
```bash
# 查看 Redis 容器日志
kubectl logs -n redis-service deployment/redis -f

# 查看最近的日志
kubectl logs -n redis-service deployment/redis --tail=100
```

## 监控和告警

### 基本监控
```bash
# 查看资源使用情况
kubectl top pod -n redis-service

# 查看 Redis 统计信息
redis-cli -h 192.168.49.2 -p 30379 info stats
```

### 性能指标
- 内存使用率
- 连接数
- 命令执行次数
- 键空间命中率

## 扩展和升级

### 垂直扩展 (增加资源)
```bash
kubectl patch deployment redis -n redis-service -p '{"spec":{"template":{"spec":{"containers":[{"name":"redis","resources":{"limits":{"memory":"1Gi","cpu":"1000m"}}}]}}}}'
```

### 版本升级
1. 备份数据
2. 更新镜像版本
3. 执行滚动更新
4. 验证服务正常

## 相关链接

- [Redis 官方文档](https://redis.io/documentation)
- [Redis 命令参考](https://redis.io/commands)
- [Kubernetes 官方文档](https://kubernetes.io/docs/)

## 技术支持

如遇到问题，请检查：
1. Kubernetes 集群状态
2. Redis 服务日志
3. 网络连接配置
4. 存储卷状态

---

**注意**: 本服务配置为开发和测试环境使用，生产环境请根据实际需求调整安全和性能配置。