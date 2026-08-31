# 06 · API 接口设计

## 一、通用规范

| 项 | 规范 |
| --- | --- |
| 协议 | HTTPS |
| 域名 | `https://api.shanheng.example.com` |
| 前缀 | App 端接口统一 `/app/v1` |
| 数据格式 | JSON，UTF-8 |
| 认证 | 登录后接口携带 `Authorization: Bearer <JWT>` |
| 分页 | `page`（从 1 开始）、`size`（默认 10，最大 50） |
| 时间 | ISO-8601 字符串 `yyyy-MM-dd HH:mm:ss` |

### 统一响应结构

```json
{
  "code": 0,
  "msg": "success",
  "data": {}
}
```

| code | 含义 |
| --- | --- |
| 0 | 成功 |
| 400 | 参数错误 |
| 401 | 未登录/Token 过期 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器错误 |

---

## 二、认证模块

### 2.1 发送验证码

`POST /app/v1/auth/send-code`

```json
{ "phone": "13800138000" }
```

返回：`{ "code": 0, "msg": "success", "data": null }`

规则：60s 防重发；验证码 5 分钟有效；存 Redis。

### 2.2 验证码登录

`POST /app/v1/auth/login-by-code`

```json
{ "phone": "13800138000", "code": "123456" }
```

返回：

```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "token": "eyJhbGciOi...",
    "refreshToken": "xxx",
    "userInfo": { "id": 1, "nickname": "用户", "avatarUrl": "..." }
  }
}
```

### 2.3 游客登录

`POST /app/v1/auth/guest`

```json
{ "deviceId": "uuid-generated-by-device" }
```

返回：JWT（游客角色）+ `userInfo.isGuest = true`。

### 2.4 华为账号登录（预留）

`POST /app/v1/auth/huawei-login`

```json
{ "authorizationCode": "xxx" }
```

后端用 code 向华为换取身份 → 注册/合并账号 → 返回 JWT。详见 `07-华为服务接入方案.md`。

### 2.5 刷新 Token / 登出

- `POST /app/v1/auth/refresh` → 新 JWT
- `POST /app/v1/auth/logout` → 失效 refresh token

---

## 三、首页模块

### 3.1 首页聚合

`GET /app/v1/home`

返回：

```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "healthSummary": {
      "authorized": true,
      "todaySteps": 8200,
      "sleepDurationMin": 390,
      "stressLevel": 1
    },
    "quickMeals": [
      { "id": 1, "name": "早餐", "iconUrl": "..." }
    ],
    "quickCategories": [
      { "id": 10, "name": "粤菜", "iconUrl": "..." }
    ],
    "todayRecommend": [
      {
        "dishId": 101,
        "name": "清蒸鲈鱼",
        "coverUrl": "...",
        "reason": "昨晚睡眠 5.8 小时，压力偏高，推荐清淡暖胃食物"
      }
    ]
  }
}
```

---

## 四、菜单发现模块

### 4.1 分类列表

`GET /app/v1/categories?type=MEAL`

返回树形分类。

### 4.2 菜品分页列表

`GET /app/v1/dishes?categoryId=1&tagIds=1,2&keyword=鸡&sort=hot&page=1&size=10`

返回：

```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "total": 100,
    "page": 1,
    "size": 10,
    "records": [
      {
        "id": 101,
        "name": "白切鸡",
        "coverUrl": "https://cdn.example.com/dish/101.webp",
        "categoryId": 10,
        "categoryName": "粤菜",
        "tags": ["高蛋白", "清淡"],
        "calorie": 450,
        "favoriteCount": 120
      }
    ]
  }
}
```

### 4.3 菜品详情

`GET /app/v1/dishes/{id}`

返回完整字段 + 是否已收藏。

### 4.4 搜索历史

- `GET /app/v1/search-history`
- `DELETE /app/v1/search-history`

---

## 五、健康数据模块

### 5.1 上报健康摘要

`POST /app/v1/health/summary`

```json
{
  "summaryDate": "2026-08-26",
  "todaySteps": 8200,
  "sleepDurationMin": 390,
  "sleepQualityScore": 72,
  "restingHeartRate": 62,
  "stressLevel": 1,
  "activityLevel": 2,
  "source": "HEALTH_KIT",
  "dataTime": "2026-08-26 08:00:00"
}
```

### 5.2 查询最新健康摘要

`GET /app/v1/health/summary/latest`

### 5.3 更新授权状态

`POST /app/v1/health/auth-status`

```json
{ "authScope": ["STEPS","SLEEP","HEART_RATE","STRESS"], "status": 1 }
```

---

## 六、推荐模块

### 6.1 生成推荐

`POST /app/v1/recommendations`

```json
{
  "scene": "午餐",
  "categoryIds": [10, 20],
  "budgetMin": 10,
  "budgetMax": 50,
  "useHealthData": true
}
```

返回：

```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "recordId": 1001,
    "recommendations": [
      {
        "dishId": 101,
        "name": "清蒸鲈鱼",
        "coverUrl": "...",
        "reason": "昨晚睡眠 5.8 小时，压力偏高，推荐清淡暖胃食物",
        "healthAdvice": "建议保证 7 小时睡眠，饮食清淡，避免高油高辣"
      }
    ],
    "alternatives": [
      { "dishId": 102, "name": "山药排骨汤", "reason": "暖胃易消化" }
    ],
    "avoidReasons": [
      { "dishId": 201, "name": "麻辣香锅", "reason": "与你忌口辣椒冲突" }
    ],
    "todayReminder": "今日步数偏低，建议餐后散步 20 分钟"
  }
}
```

### 6.2 推荐历史

`GET /app/v1/recommendations?page=1&size=10`

### 6.3 推荐反馈

`POST /app/v1/recommendations/{recordId}/feedback`

```json
{ "dishId": 101, "feedbackType": "LIKE", "reason": null }
```

---

## 七、收藏模块

- `POST /app/v1/favorites` → `{ "dishId": 101 }`
- `DELETE /app/v1/favorites/{dishId}`
- `GET /app/v1/favorites?page=1&size=10`

---

## 八、用户中心模块

### 8.1 资料

- `GET /app/v1/user/profile`
- `PUT /app/v1/user/profile` → 昵称、头像、性别

### 8.2 偏好与忌口

- `GET /app/v1/user/preference`
- `PUT /app/v1/user/preference`
- `GET /app/v1/user/avoid`
- `POST /app/v1/user/avoid`
- `DELETE /app/v1/user/avoid/{id}`

### 8.3 浏览历史

- `GET /app/v1/history?page=1&size=10`
- `DELETE /app/v1/history/{id}`

### 8.4 隐私

- `POST /app/v1/user/revoke-health-auth` → 取消健康授权
- `POST /app/v1/user/unbind-huawei` → 解绑华为账号
- `POST /app/v1/user/cancel-account` → 注销账号

---

## 九、管理端接口（若依内置，与 App 接口同一后端）

- 登录/用户/角色/菜单/日志：若依内置。
- 业务 CRUD：用若依代码生成器生成 `sh_dish`、`sh_category`、`sh_tag`、`sh_recommendation_rule` 等表的管理接口。
- 图片上传：若依通用上传改造为上传到 Cloudflare R2（后端生成预签名 URL 或后端中转）。

---

## 十、接口清单汇总（App 端）

| 模块 | 方法 | 路径 |
| --- | --- | --- |
| 认证 | POST | `/app/v1/auth/send-code` |
| 认证 | POST | `/app/v1/auth/login-by-code` |
| 认证 | POST | `/app/v1/auth/guest` |
| 认证 | POST | `/app/v1/auth/huawei-login` |
| 认证 | POST | `/app/v1/auth/refresh` |
| 认证 | POST | `/app/v1/auth/logout` |
| 首页 | GET | `/app/v1/home` |
| 分类 | GET | `/app/v1/categories` |
| 菜品 | GET | `/app/v1/dishes` |
| 菜品 | GET | `/app/v1/dishes/{id}` |
| 健康 | POST | `/app/v1/health/summary` |
| 健康 | GET | `/app/v1/health/summary/latest` |
| 健康 | POST | `/app/v1/health/auth-status` |
| 推荐 | POST | `/app/v1/recommendations` |
| 推荐 | GET | `/app/v1/recommendations` |
| 推荐 | POST | `/app/v1/recommendations/{recordId}/feedback` |
| 收藏 | POST/DELETE/GET | `/app/v1/favorites` |
| 用户 | GET/PUT | `/app/v1/user/profile` |
| 用户 | GET/PUT | `/app/v1/user/preference` |
| 用户 | GET/POST/DELETE | `/app/v1/user/avoid` |
| 历史 | GET/DELETE | `/app/v1/history` |
| 隐私 | POST | `/app/v1/user/revoke-health-auth` |
| 隐私 | POST | `/app/v1/user/unbind-huawei` |
| 隐私 | POST | `/app/v1/user/cancel-account` |
