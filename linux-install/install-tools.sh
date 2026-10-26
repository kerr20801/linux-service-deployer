#!/usr/bin/env bash
# ==============================================================================
# 🛠️ Linux 維運瑞士刀工具包 (必備常用工具)
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}>>> 正在安裝系統基礎維運工具 (htop, git, curl, jq, tmux, net-tools...)...${NC}"

if command -v apt-get &>/dev/null; then
    apt-get update -y
    apt-get install -y htop git curl wget jq tmux net-tools iotop ncdu vim ufw unzip dnsutils
elif command -v dnf &>/dev/null; then
    dnf install -y epel-release || true
    dnf install -y htop git curl wget jq tmux net-tools iotop ncdu vim unzip bind-utils
elif command -v yum &>/dev/null; then
    yum install -y epel-release || true
    yum install -y htop git curl wget jq tmux net-tools iotop ncdu vim unzip bind-utils
fi

echo -e "${GREEN}🎉 常用維運工具安裝完成！${NC}"
