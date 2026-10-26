# 🚀 Linux Service Deployer

> **極簡、現代、模組化的 Linux 常用服務一鍵部署工具庫**。  
> 徹底解決「版本碎裂與相依性衝突」痛點，整合**原生 Linux 安裝腳本**與 **Docker Compose 服務堆疊**，提供互動式終端機中控選單。

![Bash](https://img.shields.io/badge/Language-Bash%20Shell-4EAA25?logo=gnu-bash&logoColor=white)
![Docker Compose](https://img.shields.io/badge/Orchestration-Docker%20Compose%20v2-2496ED?logo=docker&logoColor=white)
![Linux Support](https://img.shields.io/badge/Linux-Ubuntu%20%7C%20Debian%20%7C%20Rocky%20%7C%20RHEL-E95420?logo=linux&logoColor=white)
[![Co-Developed with Gemini](https://img.shields.io/badge/Co--Developed%20with-Google%20Gemini-4285F4?logo=google&logoColor=white)](https://gemini.google.com)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 🎯 為什麼做這個專案？（解決核心痛點）

在日常維運與開發中，我們經常需要在全新的 Linux 主機上拉起常用的資料庫、快取與日誌系統（如 Nginx、Redis、PostgreSQL、MongoDB、Graylog、ELK）。然而傳統方式常常面臨三大痛點：
1. **版本地獄（Dependency Hell）**：寫死 `latest` 容易因大改版（如 ES 7 升 8、Graylog 換架構）導致 YAML 損壞；寫死固定版號又難以維護。
2. **多個 YAML 散落**：每個服務各自有一份 compose 檔，修改連線密碼或版號要在幾十個資料夾間反覆穿梭。
3. **原生安裝與容器化混淆**：不知道底層套件（如 Docker 引擎、基本工具包）該怎麼快速裝好。

**本專案的創新解法：**
* ⭐️ **「全域 `.env` 集中管理」**：所有服務的版本號碼（`NGINX_VERSION`、`REDIS_VERSION`、`POSTGRES_VERSION` 等）與密碼** 100% 集中在單一 `.env` 檔案**。
* ⭐️ **「`:-LTS` 安全備援機制」**：所有 Compose 檔案均配置經過實測驗證的最新穩定版作為預設值，即使沒有 `.env` 也能無腦一鍵啟動。
* ⭐️ **「互動式 TUI 選單 (`deploy.sh`)」**：連進伺服器只需打 `bash deploy.sh`，直接按數字一鍵拉起任何服務，連 Docker 指令都不必死記！

---

## 📦 支援的服務清單與預設埠號

| 服務模組 | 預設版本 (可於 .env 修改) | 服務埠號 (Port) | 附帶管理介面 (Web UI) | 預設帳號 / 密碼 |
|:---|:---|:---|:---|:---|
| **🌐 Nginx** | `1.26-alpine` | `80` (HTTP), `443` (HTTPS) | 預設歡迎頁 + 反向代理範本 | — |
| **⚡ Redis** | `7.4-alpine` | `6379` | **RedisInsight** (Port: `5540`) | 密碼: `MySecureRedisPass123!` |
| **🐘 PostgreSQL** | `16-alpine` (支援 17) | `5432` | **pgAdmin 4** (Port: `5050`) | `admin@admin.com` / `admin` |
| **🍃 MongoDB** | `7.0` (支援 8.0) | `27017` | **Mongo Express** (Port: `8081`) | `admin` / `admin` |
| **🪵 Graylog 6.0** | `6.0` (含 OpenSearch 2.15 + Mongo) | `9000` (Web), `12201` (GELF) | **Graylog Web** (Port: `9000`) | `admin` / `admin` |
| **📊 ELK Stack** | `8.15.0` (ES + Kibana) | `9200` (ES), `5601` (Kibana) | **Kibana Dashboard** (Port: `5601`) | 免證書即插即用（已預先調校） |

---

## 🚀 快速開始

### 1. 複製專案至 Linux 伺服器
```bash
git clone https://github.com/kerr20801/linux-service-deployer.git
cd linux-service-deployer
```

### 2. 一鍵啟動中控台選單
```bash
chmod +x deploy.sh
./deploy.sh
```

終端機會顯示彩色直覺選單：
```text
========================================================================
           🚀 Linux Service Deployer - 服務一鍵部署工具箱            
========================================================================
 📍 本機伺服器 IP: 192.168.1.100  | 📁 設定檔: linux-docker/.env
------------------------------------------------------------------------
 [原生 Linux 安裝 (Host Native)]
  1) 🐳 安裝 Docker & Docker Compose Plugin (官方最新引擎)
  2) 🌐 安裝 Nginx 原生服務 (APT/YUM 適配)
  3) 🟩 安裝 Node.js LTS (官方 NodeSource 源)
  4) 🛠️ 安裝維運瑞士刀工具包 (htop, git, jq, curl, tmux...)

 [Docker 容器化模組 (獨立 Stack，版本在 .env 集中調控)]
  5) 🌐 部署 Nginx (反向代理 + 靜態站 + Certbot SSL 預留)
  6) ⚡ 部署 Redis 快取 + RedisInsight 網頁管理 (Port: 6379 / 5540)
  7) 🐘 部署 PostgreSQL + pgAdmin4 資料庫管理 (Port: 5432 / 5050)
  8) 🍃 部署 MongoDB + Mongo Express 網頁管理 (Port: 27017 / 8081)
  9) 🪵 部署 Graylog 6.0 集中日誌 (含 OpenSearch+Mongo) (Port: 9000)
  10)📊 部署 ELK Stack (Elasticsearch 8.15 + Kibana) (Port: 9200 / 5601)

 [容器狀態與管理]
  11)📋 查看當前所有容器狀態 (docker ps)
  12)🛑 停止指定服務容器
  13)⚙️ 編輯/檢視 .env 版本與密碼設定檔
  0) 🚪 離開
========================================================================
請輸入功能編號 [0-13]:
```

---

## 🛠️ 如何調整服務版本與自訂密碼？

所有設定與版本號皆集中在 `linux-docker/.env`（初次執行 `deploy.sh` 時會自動為您從範本建立）。

若需要切換特定軟體版本或修改連線密碼，只要編輯該檔案即可：
```bash
nano linux-docker/.env
```

範例內容：
```bash
# 修改 Nginx 版本
NGINX_VERSION=1.26-alpine

# 修改 Redis 版本與密碼
REDIS_VERSION=7.4-alpine
REDIS_PASSWORD=YourCustomPasswordHere!

# 修改 PostgreSQL 版本
POSTGRES_VERSION=17-alpine
POSTGRES_PASSWORD=YourStrongPgPassword!

# 修改 MongoDB 版本
MONGO_VERSION=8.0
MONGO_INITDB_ROOT_PASSWORD=YourStrongMongoPassword!

# 修改 ELK 與 Graylog 版本
GRAYLOG_VERSION=6.0
OPENSEARCH_VERSION=2.15.0
ELK_VERSION=8.15.0
```
修改後在選單重新執行一次啟動即可無縫套用新版本！

---

## 📁 專案結構說明

```
linux-service-deployer/
├── deploy.sh                  # 🚀 互動式主選單啟動器
├── .env.example               # 全域版本與密碼範本
├── .gitignore                 # 自動忽略容器持久化 data/ 與日誌
│
├── linux-install/             # 原生 Linux 一鍵安裝腳本 (跨發行版自動適配)
│   ├── install-docker.sh      # 官方正規安裝 Docker CE + Compose Plugin
│   ├── install-nginx.sh       # 原生 Nginx 伺服器安裝 + 防火牆自動放行
│   ├── install-node.sh        # Node.js 官方 LTS 安裝 (支援 NODE_MAJOR 參數)
│   └── install-tools.sh       # 實用維運工具 (htop, curl, git, jq, tmux, ufw...)
│
└── linux-docker/              # 容器化服務模組 (獨立 compose 堆疊)
    ├── .env.example           # Docker 專用版本控制表
    ├── nginx/                 # Nginx 容器 (含 conf.d/ 反代範本與 certbot 掛載)
    ├── redis/                 # Redis 快取 (含 AOF/RDB 持久化) + RedisInsight 網頁管理
    ├── postgres/              # PostgreSQL 關聯資料庫 + pgAdmin4 網頁控制台
    ├── mongodb/               # MongoDB 文件資料庫 + Mongo Express 網頁控制台
    ├── graylog/               # Graylog 6.0 集中日誌中心 (整合 OpenSearch + MongoDB)
    └── elk/                   # ELK 8.x 巨量日誌分析 (Elasticsearch + Kibana)
```

---

## 🤝 Contributors & Credits

- 👨‍💻 **[Kerr](https://github.com/kerr20801)** — 專案發起、核心架構設計、測試驗證與維護
- 🤖 **[Google Gemini](https://gemini.google.com)** — AI 結對編程夥伴（Compose 堆疊編排、版本管理解耦設計與自動化腳本撰寫）

---

## 📄 License

本專案採用 [MIT License](LICENSE) 授權釋出，歡迎自由使用、擴充與分支改進！
