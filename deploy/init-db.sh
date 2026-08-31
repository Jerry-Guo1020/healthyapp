#!/usr/bin/env bash
# 膳衡 App 数据库初始化脚本（在服务器 /opt/shanheng 下执行）
# 用法：bash init-db.sh
set -e
cd "$(dirname "$0")"

PW=$(grep MYSQL_ROOT_PASSWORD .env | cut -d= -f2)
export MYSQL_PWD="$PW"

echo "== 关闭 MySQL 严格模式(过期若依 SQL 在 MySQL8 下会数据超长) =="
docker exec -i -e MYSQL_PWD="$PW" shanheng-mysql mysql -uroot -e "SET GLOBAL sql_mode='NO_ENGINE_SUBSTITUTION';"

echo "== 重建 ry-vue 库 =="
docker exec -i -e MYSQL_PWD="$PW" shanheng-mysql mysql -uroot -e 'DROP DATABASE IF EXISTS `ry-vue`; CREATE DATABASE `ry-vue` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;'

echo "== 导入 1/3 ry_vue_5.X.sql(系统表) =="
cat sql/ry_vue_5.X.sql | docker exec -i -e MYSQL_PWD="$PW" shanheng-mysql mysql -uroot --default-character-set=utf8mb4 ry-vue

echo "== 导入 2/3 ry_job.sql(任务调度) =="
cat sql/ry_job.sql | docker exec -i -e MYSQL_PWD="$PW" shanheng-mysql mysql -uroot --default-character-set=utf8mb4 ry-vue

echo "== 导入 3/3 shanheng_business.sql(膳衡业务) =="
cat sql/shanheng_business.sql | docker exec -i -e MYSQL_PWD="$PW" shanheng-mysql mysql -uroot --default-character-set=utf8mb4 ry-vue

echo "== 完成，表统计 =="
docker exec -i -e MYSQL_PWD="$PW" shanheng-mysql mysql -uroot -N -e \
  "SELECT CONCAT('总表数=', COUNT(*)) FROM information_schema.tables WHERE table_schema='ry-vue';"
docker exec -i -e MYSQL_PWD="$PW" shanheng-mysql mysql -uroot -N -e \
  "SELECT CONCAT('sys表=', COUNT(*)) FROM information_schema.tables WHERE table_schema='ry-vue' AND table_name LIKE 'sys\_%';"
docker exec -i -e MYSQL_PWD="$PW" shanheng-mysql mysql -uroot ry-vue -N -e \
  "SELECT 'sys_user',COUNT(*) FROM sys_user UNION ALL SELECT 'sys_menu',COUNT(*) FROM sys_menu UNION ALL SELECT 'sys_role',COUNT(*) FROM sys_role UNION ALL SELECT 'sys_dict_data',COUNT(*) FROM sys_dict_data;"