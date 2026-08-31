# shanheng-app · 膳衡 App 业务模块

面向鸿蒙 App 的业务模块，接口统一前缀 `/app/v1/**`。

## 分层规范（对齐 RuoYi-Vue-Plus 企业结构）

```
org.dromara.shanheng
├── controller    # 控制器：/app/v1/** 接口，只做参数校验与转发，不写业务
├── domain
│   ├── bo        # Body Object：请求体（入参）
│   ├── vo        # View Object：响应体（出参）
│   └── dto       # Data Transfer Object：内部传输
├── entity        # 实体：对应 sh_* 表，继承 BaseEntity
├── mapper        # MyBatis-Plus Mapper 接口
├── service       # 业务接口
│   └── impl      # 业务实现
├── config        # 模块级配置
└── constant      # 常量
```

## 职责边界

| 表 | 读写 | 说明 |
| --- | --- | --- |
| `sh_category/sh_tag/sh_dish/sh_recommendation_rule` | 只读 | 由管理端维护 |
| `sh_user/sh_health_summary/sh_recommendation_record/sh_favorite/sh_browse_history` | 读写 | App 端维护 |

## 开发约定

1. 接口在 `doc/06-API接口设计.md` 中已定义，实现保持一致。
2. 认证使用 App 端 JWT（与 sa-token 并存，账号 `sh_user`，与管理端 `sys_user` 隔离）。
3. 健康数据只存摘要（`sh_health_summary`），不存 Huawei Health Kit 原始数据。
4. 新增表结构同步更新 `script/sql/shanheng_business.sql` 与 `doc/05-数据库设计.md`。