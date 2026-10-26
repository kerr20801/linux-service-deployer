#!/usr/bin/env bash
# ==============================================================================
# 🚀 Linux Service Deployer - 一鍵互動式服務部署中控台
# ==============================================================================
set -euo pipefail

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$SCRIPT_DIR/linux-docker"
INSTALL_DIR="$SCRIPT_DIR/linux-install"
ENV_FILE="$DOCKER_DIR/.env"

# 自動初始化 .env 檔案
init_env() {
    if [ ! -f "$ENV_FILE" ]; then
        if [ -f "$DOCKER_DIR/.env.example" ]; then
            cp "$DOCKER_DIR/.env.example" "$ENV_FILE"
            echo -e "${GREEN}[✓] 已為您從 .env.example 自動建立 $ENV_FILE！${NC}"
        elif [ -f "$SCRIPT_DIR/.env.example" ]; then
            cp "$SCRIPT_DIR/.env.example" "$ENV_FILE"
            echo -e "${GREEN}[✓] 已為您從根目錄 .env.example 自動建立 $ENV_FILE！${NC}"
        fi
    fi
}

# 取得本機 IP (供服務網址提示)
get_host_ip() {
    local ip
    ip=$(hostname -I 2>/dev/null | awk '{print $1}') || ip="localhost"
    echo "${ip:-localhost}"
}

# 檢查 Docker 環境
check_docker() {
    if ! command -v docker &>/dev/null; then
        echo -e "${RED}[!] 系統尚未安裝 Docker！${NC}"
        read -p "是否立即執行一鍵安裝 Docker？(y/N): " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            bash "$INSTALL_DIR/install-docker.sh"
        else
            echo -e "${YELLOW}請先安裝 Docker 後再啟動容器服務。${NC}"
            return 1
        fi
    fi
    return 0
}

# Docker Compose 封裝函式 (自動加載 .env)
run_compose() {
    local service_dir="$1"
    local action="${2:-up -d}"
    init_env

    if ! check_docker; then return; fi

    echo -e "${CYAN}>>> 正在切換至 $service_dir 執行: docker compose --env-file $ENV_FILE $action...${NC}"
    (
        cd "$DOCKER_DIR/$service_dir"
        docker compose --env-file "$ENV_FILE" $action
    )
}

show_menu() {
    local host_ip
    host_ip=$(get_host_ip)

    clear
    echo -e "${CYAN}========================================================================${NC}"
    echo -e "${WHITE}           🚀 Linux Service Deployer - 服務一鍵部署工具箱            ${NC}"
    echo -e "${CYAN}========================================================================${NC}"
    echo -e " 📍 本機伺服器 IP: ${GREEN}${host_ip}${NC}  | 📁 設定檔: ${YELLOW}linux-docker/.env${NC}"
    echo -e " ${YELLOW}⚠️  提醒：版本請依需求於 .env 自行調整，切勿直接使用預設版號！${NC}"
    echo -e "${CYAN}------------------------------------------------------------------------${NC}"
    echo -e " ${GREEN}[原生 Linux 安裝 (Host Native)]${NC}"
    echo -e "  ${WHITE}1)${NC} 🐳 安裝 Docker & Docker Compose Plugin (官方最新引擎)"
    echo -e "  ${WHITE}2)${NC} 🌐 安裝 Nginx 原生服務 (APT/YUM 適配)"
    echo -e "  ${WHITE}3)${NC} 🟩 安裝 Node.js LTS (官方 NodeSource 源)"
    echo -e "  ${WHITE}4)${NC} 🛠️ 安裝維運瑞士刀工具包 (htop, git, jq, curl, tmux...)"
    echo ""
    echo -e " ${GREEN}[Docker 容器化模組 (獨立 Stack，版本在 .env 集中調控)]${NC}"
    echo -e "  ${WHITE}5)${NC} 🌐 部署 Nginx (反向代理 + 靜態站 + Certbot SSL 預留)"
    echo -e "  ${WHITE}6)${NC} ⚡ 部署 Redis 快取 + RedisInsight 網頁管理 (Port: 6379 / 5540)"
    echo -e "  ${WHITE}7)${NC} 🐘 部署 PostgreSQL + pgAdmin4 資料庫管理 (Port: 5432 / 5050)"
    echo -e "  ${WHITE}8)${NC} 🍃 部署 MongoDB + Mongo Express 網頁管理 (Port: 27017 / 8081)"
    echo -e "  ${WHITE}9)${NC} 🪵 部署 Graylog 6.0 集中日誌 (含 OpenSearch+Mongo) (Port: 9000)"
    echo -e "  ${WHITE}10)${NC}📊 部署 ELK Stack (Elasticsearch 8.15 + Kibana) (Port: 9200 / 5601)"
    echo ""
    echo -e " ${GREEN}[容器狀態與管理]${NC}"
    echo -e "  ${WHITE}11)${NC}📋 查看當前所有容器狀態 (docker ps)"
    echo -e "  ${WHITE}12)${NC}🛑 停止指定服務容器"
    echo -e "  ${WHITE}13)${NC}⚙️ 編輯/檢視 .env 版本與密碼設定檔"
    echo -e "  ${WHITE}0)${NC} 🚪 離開"
    echo -e "${CYAN}========================================================================${NC}"
}

# 主執行迴圈
main() {
    init_env
    local host_ip
    host_ip=$(get_host_ip)

    while true; do
        show_menu
        read -p "請輸入功能編號 [0-13]: " choice
        echo ""

        case "$choice" in
            1)
                echo -e "${YELLOW}>>> 執行 Docker 官方原生安裝腳本...${NC}"
                bash "$INSTALL_DIR/install-docker.sh"
                ;;
            2)
                echo -e "${YELLOW}>>> 執行 Nginx 原生安裝腳本...${NC}"
                bash "$INSTALL_DIR/install-nginx.sh"
                ;;
            3)
                echo -e "${YELLOW}>>> 執行 Node.js 原生安裝腳本...${NC}"
                bash "$INSTALL_DIR/install-node.sh"
                ;;
            4)
                echo -e "${YELLOW}>>> 安裝基礎維運工具包...${NC}"
                bash "$INSTALL_DIR/install-tools.sh"
                ;;
            5)
                run_compose "nginx" "up -d"
                echo -e "${GREEN}✓ Nginx 容器已啟動！首頁：http://${host_ip}/${NC}"
                ;;
            6)
                run_compose "redis" "up -d"
                echo -e "${GREEN}✓ Redis 容器已啟動！${NC}"
                echo -e "  • Redis Port: 6379 (密碼請見 .env)"
                echo -e "  • RedisInsight 網頁管理: http://${host_ip}:5540"
                ;;
            7)
                run_compose "postgres" "up -d"
                echo -e "${GREEN}✓ PostgreSQL 容器已啟動！${NC}"
                echo -e "  • Postgres Port: 5432"
                echo -e "  • pgAdmin4 網頁介面: http://${host_ip}:5050 (帳號: admin@admin.com / admin)"
                ;;
            8)
                run_compose "mongodb" "up -d"
                echo -e "${GREEN}✓ MongoDB 容器已啟動！${NC}"
                echo -e "  • Mongo Port: 27017"
                echo -e "  • Mongo Express 管理介面: http://${host_ip}:8081 (帳號: admin / admin)"
                ;;
            9)
                echo -e "${YELLOW}>>> 正在啟動 Graylog 6.0 日誌中心 (啟動需約 30~60 秒)...${NC}"
                run_compose "graylog" "up -d"
                echo -e "${GREEN}✓ Graylog 服務堆疊已啟動！${NC}"
                echo -e "  • Graylog Web 控制台: http://${host_ip}:9000 (預設帳號: admin / admin)"
                echo -e "  • Syslog UDP/TCP: 1514 | GELF UDP: 12201"
                ;;
            10)
                echo -e "${YELLOW}>>> 正在啟動 ELK Stack (Elasticsearch + Kibana)...${NC}"
                run_compose "elk" "up -d"
                echo -e "${GREEN}✓ ELK 服務已啟動！${NC}"
                echo -e "  • Elasticsearch API: http://${host_ip}:9200"
                echo -e "  • Kibana Web 儀表板: http://${host_ip}:5601"
                ;;
            11)
                echo -e "${CYAN}=== 當前運行中的 Docker 容器 ===${NC}"
                docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" || true
                ;;
            12)
                echo -e "${YELLOW}請選擇要停止的服務：${NC}"
                echo "1) Nginx  2) Redis  3) Postgres  4) Mongo  5) Graylog  6) ELK  7) 全部停止"
                read -p "請選擇 [1-7]: " stop_target
                case "$stop_target" in
                    1) run_compose "nginx" "down" ;;
                    2) run_compose "redis" "down" ;;
                    3) run_compose "postgres" "down" ;;
                    4) run_compose "mongodb" "down" ;;
                    5) run_compose "graylog" "down" ;;
                    6) run_compose "elk" "down" ;;
                    7)
                        for s in nginx redis postgres mongodb graylog elk; do
                            run_compose "$s" "down"
                        done
                        ;;
                    *) echo "已取消" ;;
                esac
                ;;
            13)
                if command -v nano &>/dev/null; then
                    nano "$ENV_FILE"
                elif command -v vim &>/dev/null; then
                    vim "$ENV_FILE"
                else
                    cat "$ENV_FILE"
                fi
                ;;
            0)
                echo -e "${GREEN}感謝使用 Linux Service Deployer，再見！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[!] 無效的選項，請重新輸入！${NC}"
                ;;
        esac

        echo ""
        read -p "按 Enter 鍵返回選單..." _
    done
}

main "$@"
