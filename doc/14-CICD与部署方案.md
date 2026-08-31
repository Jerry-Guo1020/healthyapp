# 14 · CI/CD 与部署方案

## 一、总体策略

| 服务 | 构建方式 | 产物 | 部署方式 |
| --- | --- | --- | --- |
| api（统一后端，RuoYi-Vue-Plus + App 模块） | Maven + Docker | `shanheng-api:latest` 镜像 | GitHub Actions → 服务器 docker compose |
| maneger-web（若依 Vue 前端） | npm + Docker（Nginx） | `ruoyi-ui:latest` 镜像 | 同上 |
| MySQL / Redis | 官方镜像 | - | 服务器 docker compose 持久化卷 |
| 鸿蒙 App | DevEco / 命令行构建（本地或华为云构建） | HAP/HAR 包 | **不走 GitHub Actions**（签名与构建依赖鸿蒙工具链） |

> 说明：鸿蒙 App 采用本地构建 + 华为云构建上架；GitHub Actions 只负责后端 jar 与前端静态资源。

## 二、目录结构

```
healthyapp/
├── .github/workflows/
│   ├── api-ci.yml           # api 后端：Maven 打包 + Docker 镜像 + 部署
│   └── manager-ui-ci.yml    # maneger-web 前端：npm 构建 + Nginx 镜像 + 部署
├── deploy/
│   ├── docker-compose.yml   # 生产编排
│   └── nginx.conf           # 反代 + 托管前端
```

## 三、GitHub Actions 工作流

### 3.1 api-ci.yml（push 到 main 触发）

```yaml
name: api-ci

on:
  push:
    branches: [ main ]
    paths:
      - 'api/**'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
          cache: maven

      - name: Build with Maven
        working-directory: api
        run: mvn -B clean package -DskipTests

      - name: Build Docker image
        working-directory: api
        run: |
          docker build -f Dockerfile -t shanheng-api:latest .

      - name: Push to registry
        run: |
          echo "${{ secrets.REGISTRY_PASSWORD }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
          docker tag shanheng-api:latest ghcr.io/${{ github.repository }}-api:latest
          docker push ghcr.io/${{ github.repository }}-api:latest

      - name: Deploy to server
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          script: |
            cd /opt/shanheng
            docker compose pull api
            docker compose up -d api
```

### 3.2 manager-ui-ci.yml（前端）

```yaml
name: manager-ui-ci

on:
  push:
    branches: [ main ]
    paths:
      - 'maneger-web/**'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      - name: Build UI
        working-directory: maneger-web/ruoyi-ui
        run: |
          npm ci
          npm run build:prod
      - name: Build Docker image
        working-directory: maneger-web/ruoyi-ui
        run: docker build -f Dockerfile -t ruoyi-ui:latest .
      - name: Push to registry
        run: |
          echo "${{ secrets.REGISTRY_PASSWORD }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
          docker tag ruoyi-ui:latest ghcr.io/${{ github.repository }}-ui:latest
          docker push ghcr.io/${{ github.repository }}-ui:latest
      - name: Deploy to server
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          script: |
            cd /opt/shanheng
            docker compose pull ruoyi-ui
            docker compose up -d ruoyi-ui
```

## 四、Docker Compose（deploy/docker-compose.yml）

```yaml
services:
  mysql:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: shanheng
      TZ: Asia/Shanghai
    volumes:
      - mysql-data:/var/lib/mysql
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_general_ci
    ports:
      - "127.0.0.1:3306:3306"

  redis:
    image: redis:7-alpine
    restart: always
    volumes:
      - redis-data:/data
    ports:
      - "127.0.0.1:6379:6379"

  api:
    image: ghcr.io/<repo>-api:latest
    restart: always
    environment:
      SPRING_PROFILES_ACTIVE: prod
    ports:
      - "8080:8080"
    depends_on: [mysql, redis]

  ruoyi-ui:
    image: ghcr.io/<repo>-ui:latest
    restart: always
    depends_on: [api]

  nginx:
    image: nginx:alpine
    restart: always
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    ports:
      - "80:80"
      - "443:443"
    depends_on: [api, ruoyi-ui]

volumes:
  mysql-data:
  redis-data:
```

## 五、Nginx 反代示意

```nginx
# 管理端前端（若依 Vue 静态资源由 ruoyi-ui 容器提供，或 nginx 直接挂载 dist）
server {
  listen 80;
  server_name admin.example.com;
  location / {
    proxy_pass http://ruoyi-ui:80;
  }
  location /prod-api/ {
    proxy_pass http://api:8080/;
  }
}

# App 端接口
server {
  listen 80;
  server_name api.example.com;
  location /app/ {
    proxy_pass http://api:8080/app/;
  }
}
```

> 生产环境务必启用 443 + HTTPS 证书（可用 Certbot / 云厂商免费证书）。

## 六、Cloudflare R2 集成

| 项 | 说明 |
| --- | --- |
| 用途 | 菜品图片、运营图片 |
| 免费额度 | 10GB 存储，每月 100 万次读/写操作，**无流量费** |
| 接入方式 | S3 兼容 API（`s3.r2.cloudflarestorage.com`） |
| Java SDK | AWS SDK S3（Endpoint 指向 R2） |
| 上传策略 | 管理端上传：后端生成预签名 URL → 前端直传 R2；或后端中转 |
| 访问 | 公开读 URL 或绑定自定义域名 `cdn.example.com` |
| 优化 | 图片压缩为 WebP、单图 ≤ 2MB、列表用缩略图 |

## 七、密钥管理

所有敏感信息通过 GitHub Secrets 与服务器 `.env` 管理，不提交仓库：

- `MYSQL_ROOT_PASSWORD`
- `JWT_SECRET`（App 端 JWT 密钥）
- `R2_ACCESS_KEY_ID` / `R2_SECRET_ACCESS_KEY`
- `HUAWEI_CLIENT_ID` / `HUAWEI_CLIENT_SECRET`
- `SERVER_HOST` / `SERVER_USER` / `SERVER_SSH_KEY`
- `REGISTRY_PASSWORD`
