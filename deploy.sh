#!/bin/bash
set -e

# ================= 配置区 =================
PROJECT_NAME="zero-to-tech"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
NGINX_BASE="/opt/nginx"
TARGET_DIR="${NGINX_BASE}/html/${PROJECT_NAME}"
CONTAINER_NAME="nginx"
# ==========================================

echo "🚀 开始部署静态项目 ${PROJECT_NAME}..."

# 1. 同步文件
echo "📂 [1/3] 同步文件到 ${TARGET_DIR}..."
mkdir -p "${TARGET_DIR}"
find "${TARGET_DIR}" -mindepth 1 -delete
cd "${SRC_DIR}"
for item in * .[!.]* ..?*; do
    [ -e "$item" ] || continue
    case "$item" in
        .git|node_modules|deploy.sh|.env*) continue ;;
    esac
    cp -a "$item" "${TARGET_DIR}/"
done
echo "✅ 文件同步完成"

# 2. 修正权限
echo "🔐 [2/3] 修正文件权限..."
chmod -R 755 "${TARGET_DIR}"
echo "✅ 权限修正完成"

# 3. 验证并重载 Nginx
echo "🔄 [3/3] 重载 Nginx..."
docker exec "${CONTAINER_NAME}" nginx -t
docker exec "${CONTAINER_NAME}" nginx -s reload

echo "✅ 部署成功! 🎉"