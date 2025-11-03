# Kibana 9.2.0 使用指南

## 📋 概述

本文档介绍如何使用 Kibana 9.2.0 进行数据可视化和 Elasticsearch 集群管理。Kibana 已配置为通过 HTTPS 安全连接到 Elasticsearch 集群。

## 🌐 访问信息

### Web 界面访问
- **URL**: `http://192.168.1.102:5601`
- **登录用户**: `elastic`
- **登录密码**: `elastic123`

### 后端连接
- **Elasticsearch**: `https://elasticsearch-service.elasticsearch.svc.cluster.local:9200`
- **服务账户**: `kibana_system`

## 🚀 快速开始

### 1. 启动 Kibana 服务
```bash
# 使用启动脚本
cd /home/k8suser/k8s-for-devops/kibana
./start-kibana-lan.sh

# 选择选项 1: 启动 Kibana 端口转发
```

### 2. 访问 Web 界面
1. 打开浏览器访问: `http://192.168.1.102:5601`
2. 输入用户名: `elastic`
3. 输入密码: `elastic123`
4. 点击登录

### 3. 首次配置
登录后，Kibana 会自动连接到 Elasticsearch 集群并显示欢迎页面。

## 📊 主要功能模块

### 1. Discover (数据发现)
用于搜索和浏览 Elasticsearch 中的数据。

#### 创建索引模式
1. 导航到 **Management** > **Stack Management** > **Index Patterns**
2. 点击 **Create index pattern**
3. 输入索引模式名称（如 `logstash-*` 或 `my-index*`）
4. 选择时间字段（如果有）
5. 点击 **Create index pattern**

#### 数据探索
1. 导航到 **Analytics** > **Discover**
2. 选择索引模式
3. 使用搜索栏进行 KQL 查询
4. 调整时间范围
5. 查看文档详情

### 2. Visualize (可视化)
创建各种图表和可视化组件。

#### 创建可视化
1. 导航到 **Analytics** > **Visualizations**
2. 点击 **Create visualization**
3. 选择可视化类型：
   - **Line Chart**: 线图
   - **Bar Chart**: 柱状图
   - **Pie Chart**: 饼图
   - **Data Table**: 数据表
   - **Metric**: 指标
   - **Heat Map**: 热力图

#### 配置示例 - 柱状图
```
1. 选择索引模式
2. Y轴配置:
   - Aggregation: Count
   - Custom Label: 文档数量

3. X轴配置:
   - Aggregation: Date Histogram
   - Field: @timestamp
   - Interval: Auto
   - Custom Label: 时间

4. 点击 "Apply changes"
5. 保存可视化
```

### 3. Dashboard (仪表板)
组合多个可视化组件创建综合仪表板。

#### 创建仪表板
1. 导航到 **Analytics** > **Dashboard**
2. 点击 **Create dashboard**
3. 点击 **Add** 添加可视化组件
4. 选择已创建的可视化
5. 调整组件大小和位置
6. 保存仪表板

### 4. Canvas (画布)
创建像素级完美的演示文稿。

#### 基本使用
1. 导航到 **Analytics** > **Canvas**
2. 点击 **Create workpad**
3. 添加元素：文本、图像、图表
4. 配置数据源和样式
5. 保存工作簿

## 🔧 管理功能

### 1. 索引管理
导航到 **Management** > **Stack Management** > **Index Management**

#### 查看索引
- 查看所有索引列表
- 监控索引大小和文档数量
- 管理索引生命周期

#### 索引操作
```bash
# 通过 Kibana Dev Tools 执行
GET _cat/indices?v

# 创建索引
PUT /my-new-index
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}

# 删除索引
DELETE /my-old-index
```

### 2. 用户和角色管理
导航到 **Management** > **Stack Management** > **Security**

#### 创建用户
1. 点击 **Users** > **Create user**
2. 填写用户信息：
   - Username: 用户名
   - Password: 密码
   - Full name: 全名
   - Email: 邮箱
3. 分配角色
4. 保存用户

#### 创建角色
1. 点击 **Roles** > **Create role**
2. 配置权限：
   - Cluster privileges
   - Index privileges
   - Application privileges
3. 保存角色

### 3. 监控和告警
导航到 **Observability** > **Alerts and Insights**

#### 设置告警规则
1. 点击 **Rules** > **Create rule**
2. 选择规则类型
3. 配置条件和阈值
4. 设置通知方式
5. 保存规则

## 🛠️ Dev Tools (开发工具)

### Console 使用
导航到 **Management** > **Dev Tools** > **Console**

#### 常用查询示例
```bash
# 查看集群健康状态
GET _cluster/health

# 查看所有索引
GET _cat/indices?v

# 搜索文档
GET /my-index/_search
{
  "query": {
    "match_all": {}
  }
}

# 聚合查询
GET /my-index/_search
{
  "size": 0,
  "aggs": {
    "daily_counts": {
      "date_histogram": {
        "field": "@timestamp",
        "calendar_interval": "day"
      }
    }
  }
}

# 创建索引模板
PUT _index_template/my-template
{
  "index_patterns": ["logs-*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    },
    "mappings": {
      "properties": {
        "@timestamp": {
          "type": "date"
        },
        "message": {
          "type": "text"
        }
      }
    }
  }
}
```

## 📈 数据导入和导出

### 1. 导入示例数据
Kibana 提供了多个示例数据集：

1. 导航到首页
2. 点击 **Try sample data**
3. 选择数据集：
   - **Sample web logs**: Web 访问日志
   - **Sample eCommerce orders**: 电商订单数据
   - **Sample flight data**: 航班数据
4. 点击 **Add data** 导入

### 2. 文件上传
1. 导航到 **Machine Learning** > **Data Visualizer**
2. 点击 **Upload file**
3. 选择 CSV、JSON 或其他格式文件
4. 配置字段映射
5. 导入到 Elasticsearch

### 3. 数据导出
```bash
# 通过 Dev Tools 导出数据
GET /my-index/_search
{
  "query": {
    "range": {
      "@timestamp": {
        "gte": "2024-01-01",
        "lte": "2024-01-31"
      }
    }
  }
}
```

## 🔍 高级搜索

### KQL (Kibana Query Language)
```bash
# 基本搜索
status:200

# 范围搜索
response_time > 100

# 通配符搜索
message:error*

# 布尔查询
status:200 AND method:GET

# 字段存在性
_exists_:user_agent

# 时间范围
@timestamp >= "2024-01-01" AND @timestamp < "2024-02-01"
```

### Lucene 查询语法
```bash
# 精确匹配
status:200

# 模糊搜索
message:erro~

# 范围查询
response_time:[100 TO 500]

# 正则表达式
message:/error.*/
```

## 🛠️ 故障排除

### 常见问题

#### 1. 无法访问 Kibana
```bash
# 检查 Pod 状态
kubectl get pods -n kibana

# 查看日志
kubectl logs -n kibana -l app=kibana

# 检查端口转发
ps aux | grep port-forward
```

#### 2. 连接 Elasticsearch 失败
```bash
# 检查 Elasticsearch 状态
kubectl get pods -n elasticsearch

# 测试连接
curl -k -u elastic:elastic123 https://192.168.1.102:9200/_cluster/health
```

#### 3. 登录失败
- 确认用户名密码正确
- 检查用户是否被锁定
- 验证用户角色权限

#### 4. 索引模式创建失败
- 确认索引存在
- 检查索引权限
- 验证时间字段格式

### 性能优化

#### 1. 查询优化
- 使用过滤器而非查询
- 限制搜索结果数量
- 合理设置时间范围

#### 2. 可视化优化
- 减少聚合层级
- 使用采样数据
- 优化刷新间隔

## 📚 学习资源

### 官方文档
- [Kibana 用户指南](https://www.elastic.co/guide/en/kibana/current/index.html)
- [可视化教程](https://www.elastic.co/guide/en/kibana/current/tutorial-build-dashboard.html)
- [KQL 语法参考](https://www.elastic.co/guide/en/kibana/current/kuery-query.html)

### 最佳实践
1. **索引模式命名**: 使用有意义的名称
2. **仪表板设计**: 保持简洁明了
3. **权限管理**: 遵循最小权限原则
4. **性能监控**: 定期检查查询性能

## 🔗 集成和扩展

### Beats 集成
- **Filebeat**: 日志文件收集
- **Metricbeat**: 系统指标收集
- **Packetbeat**: 网络数据收集
- **Heartbeat**: 服务可用性监控

### 插件和应用
- **APM**: 应用性能监控
- **SIEM**: 安全信息和事件管理
- **Uptime**: 服务监控
- **Logs**: 日志分析

---

*文档版本: 1.0*  
*更新时间: 2024-01-01*  
*适用版本: Kibana 9.2.0*