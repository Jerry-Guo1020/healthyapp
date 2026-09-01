-- =============================================================
-- 菜品营养字段增量迁移（每 100g 含量，单位 g）
-- 作用：为「联网补全营养」新增蛋白质/脂肪/碳水三列
-- 执行环境：已部署的测试/生产 MySQL（数据库 ry-vue）
-- 注意：本迁移对已有库执行一次即可；新库装 shanheng_business.sql 已包含这些列，无需执行本文件
-- =============================================================
ALTER TABLE `sh_dish`
    ADD COLUMN `protein` DECIMAL(6,2) DEFAULT NULL COMMENT '蛋白质(g/100g)' AFTER `recommend_count`,
    ADD COLUMN `fat`     DECIMAL(6,2) DEFAULT NULL COMMENT '脂肪(g/100g)' AFTER `protein`,
    ADD COLUMN `carbs`   DECIMAL(6,2) DEFAULT NULL COMMENT '碳水化合物(g/100g)' AFTER `fat`;