#!/bin/bash
set -e

# ================= 配置区 =================
PROJECT_NAME="zero-to-tech"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"        # 项目源码目录: ~/zero-to-tech
NGINX_BASE="/opt/nginx"                          # Nginx docker-compose 所在目录
TARGET_DIR="${NGINX_BASE}/html/${PROJECT_NAME}"  # 宿主机部署目标目录
CONTAINER_NAME="nginx"                           # Nginx 容器名称
# ==========================================

echo "🚀 开始部署静态项目 ${PROJECT_NAME}..."

# 1. 同步文件到 Nginx 挂载目录
echo "📂 [1/3] 同步文件到 ${TARGET_DIR}..."
mkdir -p "${TARGET_DIR}"
rsync -av --delete \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='deploy.sh' \
    --exclude='.env*' \
    "${SRC_DIR}/" "${TARGET_DIR}/"
echo "✅ 文件同步完成"

# 2. 确保权限正确 (Alpine nginx 用户)
echo "🔐 [2/3] 修正文件权限..."
chmod -R 755 "${TARGET_DIR}"
echo "✅ 权限修正完成"

# 3. 验证并重载 Nginx
echo "🔄 [3/3] 重载 Nginx..."
docker exec "${CONTAINER_NAME}" nginx -t
docker exec "${CONTAINER_NAME}" nginx -s reload

echo "✅ 部署成功! 🎉"