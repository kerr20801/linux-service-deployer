#!/usr/bin/env bash
# ==============================================================================
# 🌐 Nginx 原生服務一鍵安裝腳本 (APT / YUM 自動適配)
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

echo -e "${CYAN}>>> 正在檢查並安裝 Nginx 官方套件...${NC}"

if command -v apt-get &>/dev/null; then
    apt-get update -y
    apt-get install -y nginx
elif command -v dnf &>/dev/null; then
    dnf install -y epel-release || true
    dnf install -y nginx
elif command -v yum &>/dev/null; then
    yum install -y epel-release || true
    yum install -y nginx
else
    echo -e "${RED}[錯誤] 未支援的 Linux 發行版！${NC}"
    exit 1
fi

# 啟動與自啟
systemctl daemon-reload
systemctl enable --now nginx

# 檢查防火牆
if command -v ufw &>/dev/null && ufw status | grep -q "Status: active"; then
    echo -e "${YELLOW}>>> 開放 UFW 防火牆 80/443 (Nginx Full)...${NC}"
    ufw allow 'Nginx Full' || ufw allow 80/tcp && ufw allow 443/tcp
elif command -v firewall-cmd &>/dev/null && systemctl is-active --quiet firewalld; then
    echo -e "${YELLOW}>>> 開放 FirewallD 防火牆 http/https...${NC}"
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
fi

echo -e "${GREEN}🎉 Nginx 安裝與啟動成功！版本：$(nginx -v 2>&1)${NC}"
echo -e "${GREEN}請透過瀏覽器訪問：http://$(hostname -I | awk '{print $1}')/${NC}"
