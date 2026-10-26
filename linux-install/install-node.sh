#!/usr/bin/env bash
# ==============================================================================
# 🟩 Node.js & NPM 一鍵安裝腳本 (NodeSource 官方來源)
# 支援指定版本：NODE_MAJOR=20 或 NODE_MAJOR=22
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[錯誤] 請使用 root 或 sudo 權限執行此腳本！${NC}"
    exit 1
fi

NODE_MAJOR="${NODE_MAJOR:-20}"

echo -e "${CYAN}>>> 正在安裝 Node.js v${NODE_MAJOR}.x LTS 官方版本...${NC}"

if command -v apt-get &>/dev/null; then
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg --yes
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
    apt-get update -y
    apt-get install -y nodejs
elif command -v dnf &>/dev/null || command -v yum &>/dev/null; then
    curl -fsSL https://rpm.nodesource.com/setup_${NODE_MAJOR}.x | bash -
    yum install -y nodejs
else
    echo -e "${RED}[錯誤] 未支援的套件管理器！${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Node.js 安裝成功！${NC}"
echo -e "Node 版本: ${CYAN}$(node -v)${NC}"
echo -e "NPM  版本: ${CYAN}$(npm -v)${NC}"
