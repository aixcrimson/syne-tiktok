# 基础设施配置

本目录包含启动短视频平台所需的基础设施服务配置文件。

## 快速启动

### 1. 启动所有基础设施服务

```powershell
cd C:\project\syne-tiktok\infra\docker
docker-compose up -d
```

### 2. 验证服务状态

```powershell
# 查看运行中的容器
docker ps

# 检查各服务健康状态
docker-compose ps
```

### 3. 访问各服务

| 服务 | 地址 | 说明 |
|------|------|------|
| PostgreSQL | localhost:5432 | 数据库: syne_tiktok, 用户: postgres, 密码: postgres |
| Redis | localhost:6379 | 缓存服务 |
| Nacos | http://localhost:8848/nacos | 用户名: nacos, 密码: nacos |
| MinIO | http://localhost:9000 | 控制台: http://localhost:9001, 用户名/密码: minioadmin/minioadmin |
| RabbitMQ | http://localhost:15672 | 用户名: admin, 密码: admin123 |

## 常用命令

```powershell
# 停止所有服务
docker-compose down

# 查看日志
docker-compose logs -f

# 重启某个服务
docker-compose restart nacos

# 删除所有数据（停止服务后）
docker-compose down -v
```

## 服务说明

- **PostgreSQL**: 关系型数据库，存储视频、用户等业务数据
- **Redis**: 缓存和会话存储
- **Nacos**: 服务注册发现与配置中心
- **MinIO**: 对象存储，用于存储视频文件和图片
- **RabbitMQ**: 消息队列（当前版本暂未使用，可后续集成）