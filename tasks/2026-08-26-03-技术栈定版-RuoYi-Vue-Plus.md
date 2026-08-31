# 任务日志 2026-08-26-03 · 技术栈定版：RuoYi-Vue-Plus（方案 B）

## 一、任务目标

回应用户对"RuoYi 主线版本较低（Java 8 / Spring Boot 2.5）"的顾虑，在"是否拆两个后端"之间做最终决策，并同步文档。

## 二、决策结果

**采用方案 B：单后端 + RuoYi-Vue-Plus**（dromara 社区增强版）。

- 技术栈：Spring Boot 3.x + JDK 17 + MyBatis-Plus + sa-token + Vue3 前端。
- 架构不变：`api/` 统一后端（Plus 后端模块 + `shanheng-app` 业务模块），`maneger-web/` 只放管理端 Vue3 前端。
- 认证：管理端 sa-token（Plus 默认），App 端 JWT（复用 sa-token JWT 插件或自写过滤器）。

**决策逻辑**：
- "版本低"这个理由不能靠"拆两个后端"解决（拆分后管理端仍是旧 RuoYi）。
- 想要新版本应换"支持新版本的若依底座"——即 RuoYi-Vue-Plus。
- 因此保留单后端，同时获得现代技术栈。

## 三、本次修改文件

| 文件 | 修改内容 |
| --- | --- |
| `doc/README.md` | 关键决策表、文档导航：更新为 RuoYi-Vue-Plus |
| `doc/04-技术架构设计.md` | 技术栈、认证双轨、工程结构：改为 Boot3/JDK17/MyBatis-Plus/sa-token |
| `doc/13-管理后台平台方案.md` | 整体重写为 RuoYi-Vue-Plus 方案 |
| `doc/14-CICD与部署方案.md` | GitHub Actions JDK 8 → JDK 17，服务名更新 |
| `doc/10-MVP开发计划.md` | M0 初始化任务更新 |

## 四、风险与注意

1. RuoYi-Vue-Plus 是社区增强版，迭代快、结构可能与官方原版不同 → **开工前锁定稳定 release tag**，以该版本仓库结构为准，不追 latest。
2. Plus 用 sa-token 而非 Spring Security → App 端 JWT 集成方式以 Plus 官方文档为准。
3. 模块名（如是否有 ruoyi-quartz 等）以实际拉取版本为准。

## 五、下一步建议

1. 锁定 RuoYi-Vue-Plus 稳定版本并拉取，后端放 `api/`、前端放 `maneger-web/`。
2. 新建 `shanheng-app` 模块，配置 App JWT。
3. 每完成一步在 `tasks/` 追加日志。