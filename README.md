# 膳衡 App（HealthyApp）— 单仓库（Monorepo）

> 懂你的健康，也懂你的胃。

面向华为生态的健康饮食决策平台：结合华为运动健康数据与菜单推荐能力，帮用户决定"这一餐吃什么"。

## 仓库结构

```
healthyapp/
├── app/            # 鸿蒙 ArkTS 前端（HarmonyOS NEXT / ArkUI）
├── api/            # 统一后端：RuoYi-Vue-Plus 5.X（Spring Boot 3.5 + JDK 17）
│   └── ruoyi-modules/shanheng-app/   # 膳衡 App 业务模块
├── maneger-web/    # 管理端前端（plus-ui，Vue3 + ElementPlus）
├── deploy/         # Docker Compose + Nginx（生产部署）
├── script/         # SQL 脚本
├── doc/            # 项目文档（需求、架构、数据库、API、测试、风险等）
├── tasks/          # AI 协作任务日志（新会话先读最新日志）
└── .github/        # GitHub Actions 工作流
```

## 技术栈

| 端 | 技术 |
| --- | --- |
| 前端 | ArkTS + ArkUI（HarmonyOS NEXT, API 24） |
| 后端 | RuoYi-Vue-Plus 5.6.2 · Spring Boot 3.5 · JDK 17 · MyBatis-Plus · sa-token |
| 管理端 | plus-ui 2.6.2 · Vue3 + ElementPlus + TS |
| 数据 | MySQL 8.0 · Redis 7 · Docker Compose |
| 对象存储 | Cloudflare R2 |

## 快速开始

- 完整文档：见 [`doc/README.md`](doc/README.md)
- 协作规范：每次任务后在 `tasks/` 追加日志，新 AI 会话先读日志
- 数据库 DDL：见 [`script/sql/`](script/sql/)
- 部署：见 [`deploy/`](deploy/)