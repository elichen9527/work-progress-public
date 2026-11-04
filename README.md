# work-progress-public

以 Bash 腳本協助在 Git Repository 中驗證並提交 Textile 格式的每日或技術工作紀錄。此公開版只提供程式碼，不包含任何工作紀錄、技術報告、範本或內部設定。

## 目錄結構

```text
scripts/
  publish-daily.sh       驗證並發布單日工作紀錄
  publish-technical.sh   驗證並發布一份或多份技術紀錄
  publish-dual.sh        將當日工作紀錄與一份或多份技術紀錄一起發布
```

## 執行環境與相依套件

- Bash 4 或更新版本（關聯陣列）。
- Git，且目前分支為 `main`。
- GNU `date`（`date -d`）及 `grep`。
- Git 遠端 `origin` 已設定，並有權限執行 `git pull --ff-only origin main` 及推送至 `origin main`。

腳本不會儲存或讀取 GitHub Token；Git 認證由使用者現有的 Git 設定提供。

## 安裝與使用

```bash
git clone https://github.com/elichen9527/work-progress-public.git
cd work-progress-public

# 發布指定日期；省略日期時使用台北時區的今天
bash scripts/publish-daily.sh [YYYY-MM-DD]

# 發布一份或多份技術紀錄
bash scripts/publish-technical.sh topic-slug [topic-slug ...]

# 將今天的每日紀錄與技術紀錄在同一個 Commit 發布
bash scripts/publish-dual.sh YYYY-MM-DD topic-slug [topic-slug ...]
```

`topic-slug` 僅接受小寫英數字與單一連字號分隔的組合，例如 `device-setup`。

## 必要輸入與發布行為

這些腳本不附帶輸入紀錄。執行時，目標 Repository 必須已具備下列檔案：

- `publish-daily.sh`：`daily/YYYY-MM-DD.textile`，首行須為 `h1. YYYY/MM/DD`，且至少有一行以 `* ` 開始。
- `publish-technical.sh`：每個 slug 對應 `technical/<slug>.textile`，須有非空的 `h1.` 標題及至少一個 `h2. ` 標題。
- `publish-dual.sh`：上述每日紀錄與每個指定的技術紀錄；日期必須是台北時區的今天。

腳本會檢查分支、輸入檔案的基本格式及部分未提交變更，再明確加入指定路徑、建立 Commit，並推送至 `origin main`。它們只檢查格式，不會檢查紀錄是否含有機密、客戶資料或其他不宜公開的內容。

## 功能限制與安全注意事項

- `daily/`、`weekly/`、`technical/`、`config/`、`prompts/`、`skills/` 及 `templates/` 均刻意不納入本公開版；`.gitignore` 也會忽略這些路徑。公開 Repo 不含可直接供腳本發布的紀錄。
- 這些腳本原本用於具備相應紀錄及遠端設定的工作流程，不是獨立的報告產生器。若要使用，請在自己的私有工作目錄提供輸入檔，並先確認 `origin` 指向預期的 Repo；推送目的地的可見性由該 Repo 決定。
- 不要在公開 Repo 加入私人紀錄或機密，也不要把 `.gitignore` 當成內容審查或機密掃描的替代品。
- 腳本假設使用 `main` 分支及 `origin` 遠端；不支援其他分支或遠端名稱。結構檢查不代表內容正確或已完成隱私審查。
