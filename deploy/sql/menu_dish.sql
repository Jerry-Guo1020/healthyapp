-- =============================================================
-- 膳衡 App 管理端菜单（菜品管理）
-- 目录「膳衡业务」+ 菜单「菜品管理」+ 4 个按钮权限
-- 幂等：重复执行先删除本菜单区间
-- 执行：cat menu_dish.sql | docker exec -i -e MYSQL_PWD="$PW" \
--        shanheng-mysql mysql -uroot --default-character-set=utf8mb4 ry-vue
-- =============================================================

DELETE FROM `sys_menu` WHERE `menu_id` BETWEEN 2000 AND 2005;

-- 一级目录：膳衡业务
INSERT INTO `sys_menu` VALUES
('2000', '膳衡业务', '0', '6', 'shanheng', NULL, '', 1, 0, 'M', '0', '0', '', 'food', 103, 1, sysdate(), NULL, NULL, '膳衡健康饮食平台业务管理目录');

-- 菜单：菜品管理
INSERT INTO `sys_menu` VALUES
('2001', '菜品管理', '2000', '1', 'dish', 'shanheng/dish/index', '', 1, 0, 'C', '0', '0', 'shanheng:dish:list', 'food', 103, 1, sysdate(), NULL, NULL, '菜品管理菜单');

-- 按钮权限
INSERT INTO `sys_menu` VALUES
('2002', '菜品查询', '2001', '1', '', '', '', 1, 0, 'F', '0', '0', 'shanheng:dish:query',  '#', 103, 1, sysdate(), NULL, NULL, ''),
('2003', '菜品新增', '2001', '2', '', '', '', 1, 0, 'F', '0', '0', 'shanheng:dish:add',     '#', 103, 1, sysdate(), NULL, NULL, ''),
('2004', '菜品修改', '2001', '3', '', '', '', 1, 0, 'F', '0', '0', 'shanheng:dish:edit',    '#', 103, 1, sysdate(), NULL, NULL, ''),
('2005', '菜品删除', '2001', '4', '', '', '', 1, 0, 'F', '0', '0', 'shanheng:dish:remove',  '#', 103, 1, sysdate(), NULL, NULL, '');