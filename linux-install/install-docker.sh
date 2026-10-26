#!/usr/bin/env bash
# ==============================================================================
# 🐳 Docker & Docker Compose Plugin 一鍵安裝腳本 (官方正規方式)
# 支援：Ubuntu, Debian, Rocky Linux, AlmaLinux, CentOS, RHEL, Fedora
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}================================================================${NC}"
echo -e "${CYAN}🚀 開始安裝 Docker 引擎與 Docker Compose Plugin...${NC}"
echo -e "${CYAN}================================================================${NC}"

# 1. 檢查 root 權限
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[錯誤] 請使用 root 或 sudo 權限執行此腳本！${NC}"
    exit 1
fi

# 2. 檢查是否已經安裝
if command -v docker &>/dev/null; then
    echo -e "${GREEN}[✓] Docker 已安裝在系統中：$(docker --version)${NC}"
    if docker compose version &>/dev/null; then
        echo -e "${GREEN}[✓] Docker Compose 已安裝：$(docker compose version)${NC}"
    fi
    echo -e "${YELLOW}如需重新安裝或修復，請先手動解除安裝舊版本。${NC}"
    exit 0
fi

# 3. 安裝前置工具
echo -e "${YELLOW}>>> 安裝下載與前置證書套件 (curl, ca-certificates)...${NC}"
if command -v apt-get &>/dev/null; then
    apt-get update -y
    apt-get install -y curl ca-certificates gnupg
elif command -v dnf &>/dev/null; then
    dnf install -y curl ca-certificates
elif command -v yum &>/dev/null; then
    yum install -y curl ca-certificates
fi

# 4. 調用 Docker 官方一鍵安裝腳本
echo -e "${YELLOW}>>> 連線微軟/Docker 官方腳本 (get.docker.com) 安裝最新穩定版...${NC}"
curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sh /tmp/get-docker.sh
rm -f /tmp/get-docker.sh

# 5. 啟動並設定開機自啟動
echo -e "${YELLOW}>>> 啟動 Docker 服務並設為開機自啟...${NC}"
systemctl daemon-reload
systemctl enable --now docker

# 6. 配置普通使用者免 sudo 權限 (如果當前是由 sudo 調用)
TARGET_USER="${SUDO_USER:-}"
if [ -n "$TARGET_USER" ] && [ "$TARGET_USER" != "root" ]; then
    echo -e "${YELLOW}>>> 將使用者 [${TARGET_USER}] 加入 docker 權限組...${NC}"
    usermod -aG docker "$TARGET_USER"
    echo -e "${GREEN}[提示] 使用者 ${TARGET_USER} 已加入 docker 群組，請重新登入或執行 'newgrp docker' 即可免 sudo 執行 docker！${NC}"
fi

# 7. 驗證安裝結果
echo -e "${CYAN}================================================================${NC}"
echo -e "${GREEN}🎉 Docker 安裝成功！${NC}"
docker --version
docker compose version
echo -e "${CYAN}================================================================${NC}"
