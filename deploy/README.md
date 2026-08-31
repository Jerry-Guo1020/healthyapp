# 部署说明

## 一、初始化数据库（首次部署前执行）

进入 MySQL，按顺序执行：

```sql
-- 1. 若依框架基础表（含登录用户/菜单/字典等）
source script/sql/ry_vue_5.X.sql;
-- 2. 定时任务表
source script/sql/ry_job.sql;
-- 3. 膳衡业务表
source script/sql/shanheng_business.sql;
-- 4. 工作流表（可选；若不用工作流可跳过，但需在 admin 依赖中去掉 ruoyi-workflow）
source script/sql/ry_workflow.sql;
```

> SQL 脚本位于 `api/script/sql/`。

## 二、本地构建部署

```bash
cd deploy
cp .env.example .env
docker compose up -d --build
```

后端镜像构建需要先打包：`mvnw -B clean package`（生成 `api/ruoyi-admin/target/ruoyi-admin.jar`）。

## 三、生产部署（配合 GitHub Actions）

1. 服务器准备 `deploy/` 目录与 `.env`（设置 `IMAGE_PREFIX=ghcr.io/<owner>/<repo>`）。
2. CI 推送镜像到 GHCR 后，服务器执行：

```bash
export IMAGE_PREFIX=ghcr.io/<owner>/<repo>
docker compose pull
docker compose up -d
```

## 四、访问

| 入口 | 地址 |
| --- | --- |
| 管理端前端 | http://服务器IP/ |
| 管理端接口 | http://服务器IP/prod-api/ |
| App 端接口 | http://服务器IP/app/v1/ |

生产环境务必挂 443 + HTTPS 证书。
## CI 镜像

由 GitHub Actions 自动构建并推送（GHCR）：

- 后端：`ghcr.io/jerry-guo1020/healthyapp/api:latest`
- 前端：`ghcr.io/jerry-guo1020/healthyapp/web:latest`
