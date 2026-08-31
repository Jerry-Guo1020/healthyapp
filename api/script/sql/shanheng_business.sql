-- =============================================================
-- 膳衡 App 业务表（sh_*）
-- MySQL 8.0 / utf8mb4 / InnoDB
-- 说明：只存健康摘要，不存 Health Kit 原始数据
-- =============================================================

-- 用户表
CREATE TABLE `sh_user` (
  `id`              BIGINT       NOT NULL COMMENT '用户ID',
  `phone`           VARCHAR(20)  DEFAULT NULL COMMENT '手机号（登录账号，唯一）',
  `nickname`        VARCHAR(50)  DEFAULT NULL COMMENT '昵称',
  `avatar_url`      VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
  `gender`          TINYINT      DEFAULT 0 COMMENT '性别 0未知 1男 2女',
  `is_guest`        TINYINT      DEFAULT 0 COMMENT '是否游客 0否 1是',
  `status`          TINYINT      DEFAULT 1 COMMENT '状态 0禁用 1正常',
  `last_login_time` DATETIME     DEFAULT NULL COMMENT '最后登录时间',
  `deleted`         TINYINT      DEFAULT 0 COMMENT '逻辑删除 0否 1是',
  `create_time`     DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`     DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 第三方账号绑定表
CREATE TABLE `sh_user_auth` (
  `id`          BIGINT      NOT NULL COMMENT 'ID',
  `user_id`     BIGINT      NOT NULL COMMENT '用户ID',
  `auth_type`   VARCHAR(20) NOT NULL COMMENT '认证类型 HUAWEI/PHONE',
  `open_id`     VARCHAR(64) DEFAULT NULL COMMENT '华为OpenID',
  `union_id`    VARCHAR(64) DEFAULT NULL COMMENT '华为UnionID',
  `phone`       VARCHAR(20) DEFAULT NULL COMMENT '华为账号手机号',
  `status`      TINYINT     DEFAULT 1 COMMENT '绑定状态 0解绑 1绑定',
  `bind_time`   DATETIME    DEFAULT NULL COMMENT '绑定时间',
  `unbind_time` DATETIME    DEFAULT NULL COMMENT '解绑时间',
  `create_time` DATETIME    DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_union` (`auth_type`,`union_id`),
  UNIQUE KEY `uk_open`  (`auth_type`,`open_id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='第三方账号绑定表';

-- 用户偏好表
CREATE TABLE `sh_user_preference` (
  `id`                 BIGINT        NOT NULL COMMENT 'ID',
  `user_id`            BIGINT        NOT NULL COMMENT '用户ID',
  `taste_preference`   JSON          DEFAULT NULL COMMENT '口味偏好 {"spicy":0,"light":1}',
  `cuisine_preference` JSON          DEFAULT NULL COMMENT '菜系偏好 ["粤菜","川菜"]',
  `budget_min`         DECIMAL(10,2) DEFAULT NULL COMMENT '预算下限',
  `budget_max`         DECIMAL(10,2) DEFAULT NULL COMMENT '预算上限',
  `health_goal`        VARCHAR(20)   DEFAULT NULL COMMENT '健康目标 LOSE_FAT/MUSCLE_GAIN/STOMACH/SUGAR_CONTROL',
  `create_time`        DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`        DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户偏好表';

-- 用户忌口表
CREATE TABLE `sh_user_avoid` (
  `id`          BIGINT      NOT NULL COMMENT 'ID',
  `user_id`     BIGINT      NOT NULL COMMENT '用户ID',
  `avoid_type`  VARCHAR(20) NOT NULL COMMENT '类型 ALLERGEN过敏原/AVOID忌口',
  `item_name`   VARCHAR(50) NOT NULL COMMENT '忌口项 如花生/辣椒/麸质',
  `create_time` DATETIME    DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_item` (`user_id`,`avoid_type`,`item_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户忌口表';

-- 健康授权记录表
CREATE TABLE `sh_health_auth` (
  `id`             BIGINT   NOT NULL COMMENT 'ID',
  `user_id`        BIGINT   NOT NULL COMMENT '用户ID',
  `auth_scope`     JSON     DEFAULT NULL COMMENT '授权范围 ["STEPS","SLEEP","HEART_RATE","STRESS"]',
  `status`         TINYINT  DEFAULT 1 COMMENT '状态 0已撤销 1已授权',
  `authorize_time` DATETIME DEFAULT NULL COMMENT '授权时间',
  `revoke_time`    DATETIME DEFAULT NULL COMMENT '撤销时间',
  `create_time`    DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='健康数据授权记录表';

-- 用户健康摘要表（只存摘要，不存原始数据）
CREATE TABLE `sh_health_summary` (
  `id`                  BIGINT   NOT NULL COMMENT 'ID',
  `user_id`             BIGINT   NOT NULL COMMENT '用户ID',
  `summary_date`        DATE     NOT NULL COMMENT '摘要日期',
  `today_steps`         INT      DEFAULT NULL COMMENT '今日步数',
  `sleep_duration_min`  INT      DEFAULT NULL COMMENT '睡眠时长(分钟)',
  `sleep_quality_score` TINYINT  DEFAULT NULL COMMENT '睡眠质量评分0-100',
  `resting_heart_rate`  INT      DEFAULT NULL COMMENT '静息心率(bpm)',
  `stress_level`        TINYINT  DEFAULT NULL COMMENT '压力等级 1低 2中 3高',
  `activity_level`      TINYINT  DEFAULT NULL COMMENT '活动量 1低 2中 3高',
  `source`              VARCHAR(20) DEFAULT 'MANUAL' COMMENT '来源 HEALTH_KIT/MANUAL',
  `data_time`           DATETIME DEFAULT NULL COMMENT '数据采集时间',
  `create_time`         DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_date` (`user_id`,`summary_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户健康摘要表';

-- 菜品分类表
CREATE TABLE `sh_category` (
  `id`          BIGINT      NOT NULL COMMENT '分类ID',
  `parent_id`   BIGINT      DEFAULT 0 COMMENT '父分类ID 0为顶级',
  `name`        VARCHAR(50) NOT NULL COMMENT '分类名称',
  `type`        VARCHAR(20) DEFAULT NULL COMMENT '类型 MEAL餐次/CUISINE菜系/STAPLE主食/HEALTH健康/TASTE口味',
  `icon_url`    VARCHAR(255) DEFAULT NULL COMMENT '图标URL',
  `sort`        INT         DEFAULT 0 COMMENT '排序值(越小越靠前)',
  `is_quick`    TINYINT     DEFAULT 0 COMMENT '是否首页快捷入口 0否 1是',
  `status`      TINYINT     DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `deleted`     TINYINT     DEFAULT 0 COMMENT '逻辑删除',
  `create_dept` BIGINT      DEFAULT NULL COMMENT '创建部门',
  `create_by`   BIGINT      DEFAULT NULL COMMENT '创建人',
  `create_time` DATETIME    DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by`   BIGINT      DEFAULT NULL COMMENT '更新人',
  `update_time` DATETIME    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_parent` (`parent_id`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜品分类表';

-- 标签表
CREATE TABLE `sh_tag` (
  `id`          BIGINT      NOT NULL COMMENT '标签ID',
  `name`        VARCHAR(50) NOT NULL COMMENT '标签名 如 高蛋白/清淡/辣味',
  `type`        VARCHAR(20) DEFAULT 'HEALTH' COMMENT '类型 HEALTH健康/TASTE口味/SCENE场景',
  `sort`        INT         DEFAULT 0 COMMENT '排序值',
  `status`      TINYINT     DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_dept` BIGINT      DEFAULT NULL COMMENT '创建部门',
  `create_by`   BIGINT      DEFAULT NULL COMMENT '创建人',
  `create_time` DATETIME    DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by`   BIGINT      DEFAULT NULL COMMENT '更新人',
  `update_time` DATETIME    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='标签表';

-- 菜品表
CREATE TABLE `sh_dish` (
  `id`              BIGINT        NOT NULL COMMENT '菜品ID',
  `name`            VARCHAR(100)  NOT NULL COMMENT '菜品名称',
  `category_id`     BIGINT        NOT NULL COMMENT '主分类ID',
  `description`     TEXT          COMMENT '描述',
  `cover_url`       VARCHAR(255)  DEFAULT NULL COMMENT '封面图URL(R2)',
  `ingredients`     JSON          DEFAULT NULL COMMENT '食材 ["鸡胸肉","西兰花"]',
  `calorie`         INT           DEFAULT NULL COMMENT '热量(kcal/份)',
  `spicy_level`     TINYINT       DEFAULT 0 COMMENT '辣度 0-3',
  `oil_level`       TINYINT       DEFAULT 0 COMMENT '油度 0-3',
  `is_light`        TINYINT       DEFAULT 0 COMMENT '是否清淡 0否 1是',
  `is_warm`         TINYINT       DEFAULT 0 COMMENT '是否暖胃 0否 1是',
  `is_easy_digest`  TINYINT       DEFAULT 0 COMMENT '是否易消化 0否 1是',
  `price_min`       DECIMAL(10,2) DEFAULT NULL COMMENT '价格区间(可选)',
  `price_max`       DECIMAL(10,2) DEFAULT NULL COMMENT '价格区间(可选)',
  `status`          TINYINT       DEFAULT 3 COMMENT '状态 0草稿 1上架 2下架 3待审核',
  `view_count`      INT           DEFAULT 0 COMMENT '浏览数',
  `favorite_count`  INT           DEFAULT 0 COMMENT '收藏数',
  `recommend_count` INT           DEFAULT 0 COMMENT '被推荐次数',
  `deleted`         TINYINT       DEFAULT 0 COMMENT '逻辑删除',
  `create_dept`     BIGINT        DEFAULT NULL COMMENT '创建部门',
  `create_by`       BIGINT        DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT        DEFAULT NULL COMMENT '更新人',
  `create_time`     DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`     DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_status` (`status`),
  KEY `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜品表';

-- 菜品标签关系表
CREATE TABLE `sh_dish_tag` (
  `id`      BIGINT NOT NULL COMMENT 'ID',
  `dish_id` BIGINT NOT NULL COMMENT '菜品ID',
  `tag_id`  BIGINT NOT NULL COMMENT '标签ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dish_tag` (`dish_id`,`tag_id`),
  KEY `idx_tag` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜品标签关系表';

-- 推荐规则表
CREATE TABLE `sh_recommendation_rule` (
  `id`              BIGINT       NOT NULL COMMENT 'ID',
  `rule_name`       VARCHAR(100) NOT NULL COMMENT '规则名',
  `rule_key`        VARCHAR(50)  NOT NULL COMMENT '规则标识',
  `conditions`      JSON         NOT NULL COMMENT '触发条件 {"sleep_duration_min":{"lt":360}}',
  `action`          VARCHAR(20)  NOT NULL COMMENT '动作 INCLUDE/EXCLUDE/ADD_SCORE/SUB_SCORE',
  `score`           INT          DEFAULT 0 COMMENT '分值',
  `tag_id`          BIGINT       DEFAULT NULL COMMENT '目标标签ID',
  `reason_template` VARCHAR(255) DEFAULT NULL COMMENT '推荐理由模板',
  `priority`        INT          DEFAULT 0 COMMENT '优先级',
  `status`          TINYINT      DEFAULT 1 COMMENT '状态 0停用 1启用',
  `create_dept`     BIGINT       DEFAULT NULL COMMENT '创建部门',
  `create_by`       BIGINT       DEFAULT NULL COMMENT '创建人',
  `create_time`     DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by`       BIGINT       DEFAULT NULL COMMENT '更新人',
  `update_time`     DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_rule_key` (`rule_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='推荐规则表';

-- 推荐记录表
CREATE TABLE `sh_recommendation_record` (
  `id`             BIGINT   NOT NULL COMMENT 'ID',
  `user_id`        BIGINT   NOT NULL COMMENT '用户ID',
  `scene`          VARCHAR(20) DEFAULT NULL COMMENT '场景 早餐/午餐/晚餐/下午茶/宵夜',
  `input_snapshot` JSON     DEFAULT NULL COMMENT '输入快照(场景/偏好/健康摘要)',
  `dish_ids`       VARCHAR(255) DEFAULT NULL COMMENT '推荐菜品ID列表',
  `reason`         TEXT     COMMENT '推荐理由',
  `create_time`    DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '推荐时间',
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='推荐记录表';

-- 推荐反馈表
CREATE TABLE `sh_recommend_feedback` (
  `id`            BIGINT      NOT NULL COMMENT 'ID',
  `record_id`     BIGINT      NOT NULL COMMENT '推荐记录ID',
  `user_id`       BIGINT      NOT NULL COMMENT '用户ID',
  `dish_id`       BIGINT      NOT NULL COMMENT '菜品ID',
  `feedback_type` VARCHAR(20) NOT NULL COMMENT '反馈类型 LIKE/DISLIKE',
  `reason`        VARCHAR(100) DEFAULT NULL COMMENT '原因 太辣/太油/价格高',
  `create_time`   DATETIME    DEFAULT CURRENT_TIMESTAMP COMMENT '反馈时间',
  PRIMARY KEY (`id`),
  KEY `idx_record` (`record_id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='推荐反馈表';

-- 收藏表
CREATE TABLE `sh_favorite` (
  `id`          BIGINT   NOT NULL COMMENT 'ID',
  `user_id`     BIGINT   NOT NULL COMMENT '用户ID',
  `dish_id`     BIGINT   NOT NULL COMMENT '菜品ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_dish` (`user_id`,`dish_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

-- 浏览历史表
CREATE TABLE `sh_browse_history` (
  `id`          BIGINT   NOT NULL COMMENT 'ID',
  `user_id`     BIGINT   DEFAULT NULL COMMENT '用户ID(游客为空)',
  `device_id`   VARCHAR(64) DEFAULT NULL COMMENT '游客设备标识',
  `dish_id`     BIGINT   NOT NULL COMMENT '菜品ID',
  `browse_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '浏览时间',
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_device` (`device_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='浏览历史表';