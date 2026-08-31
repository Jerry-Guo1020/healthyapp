#!/usr/bin/env bash
# 膳衡 App 服务器主动拉取部署脚本（由 cron 定时调用，也可手动执行）
# 模型：GitHub Actions 构建并推送镜像到 GHCR，服务器定时拉取并重启容器。
set -e
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
cd "$(dirname "$0")"

echo "===== $(date '+%F %T') 检查镜像更新 ====="
docker compose pull api web
docker compose up -d api web
# 清理无标签旧镜像，避免磁盘被旧版本占满
docker image prune -f
echo "===== $(date '+%F %T') 完成 ====="