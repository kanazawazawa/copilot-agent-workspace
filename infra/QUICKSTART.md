# Azure インフラストラクチャ - クイックスタート

このディレクトリには、Copilot Agent Workspace を Azure にデプロイするためのインフラストラクチャコードが含まれています。

---

## 📂 ファイル構成

```
infra/
├── main.bicep                           # Azure リソース定義（IaC）
├── main.parameters.template.json        # パラメータテンプレート（Git 管理）
├── main.parameters.json                 # 実際のパラメータ（.gitignore 対象）
├── README.md                            # Azure CLI を使った詳細手順
├── SETUP_WITH_COPILOT_CLI.md           # Copilot CLI を使った対話的手順
└── QUICKSTART.md                        # このファイル
```

---

## 🎯 どの手順を使うべきか？

### 🤖 Copilot CLI を使った対話的デプロイ（推奨）
**こんな人におすすめ**:
- Copilot CLI を試してみたい
- コマンドの意味を理解しながら進めたい
- 自動化よりも学習を優先

👉 **[SETUP_WITH_COPILOT_CLI.md](SETUP_WITH_COPILOT_CLI.md)** を参照

---

### ⚡ Azure CLI を使った直接デプロイ
**こんな人におすすめ**:
- すでに Azure CLI に慣れている
- 手早くデプロイしたい
- 自動化スクリプトとして組み込みたい

👉 **[README.md](README.md)** を参照

---

## 🚀 5分でデプロイ（最速手順）

### 前提条件
```bash
# Azure CLI インストール確認
az --version

# ログイン
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### デプロイ
```bash
# 1. リソースグループ作成
az group create --name rg-copilot-agent-workspace --location japaneast

# 2. パラメータファイル準備
cd infra
cp main.parameters.template.json main.parameters.json
# main.parameters.json を編集（githubOwner を変更）

# 3. デプロイ
# bash/Linux の場合:
az deployment group create \
  --resource-group rg-copilot-agent-workspace \
  --template-file main.bicep \
  --parameters main.parameters.json \
  --name "deploy-$(date +%Y%m%d-%H%M%S)"

# PowerShell の場合:
az deployment group create `
  --resource-group rg-copilot-agent-workspace `
  --template-file main.bicep `
  --parameters main.parameters.json `
  --name "deploy-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# 4. 出力値を取得
az deployment group show \
  --resource-group rg-copilot-agent-workspace \
  --name "deploy-YYYYMMDD-HHMMSS" \
  --query properties.outputs
```

### GitHub Secrets 登録
```powershell
# デプロイ出力から値を取得
$outputs = (az deployment group show `
  --resource-group rg-copilot-agent-workspace `
  --name "deploy-YYYYMMDD-HHMMSS" `
  --query properties.outputs | ConvertFrom-Json)

# 4つの Secret を登録
gh secret set AZURE_CLIENT_ID `
  --repo YOUR_USERNAME/copilot-agent-workspace `
  --body $outputs.managedIdentityClientId.value

gh secret set AZURE_TENANT_ID `
  --repo YOUR_USERNAME/copilot-agent-workspace `
  --body $outputs.tenantId.value

gh secret set AZURE_STORAGE_ACCOUNT_NAME `
  --repo YOUR_USERNAME/copilot-agent-workspace `
  --body $outputs.storageAccountName.value

gh secret set AZURE_SUBSCRIPTION_ID `
  --repo YOUR_USERNAME/copilot-agent-workspace `
  --body (az account show --query id -o tsv)

# 旧 Secret を削除（キー認証は不要になった）
gh secret delete AZURE_STORAGE_CONNECTION_STRING `
  --repo YOUR_USERNAME/copilot-agent-workspace
```

---

## 📦 デプロイされるリソース

| リソース | SKU | 月額概算（日本東部） |
|---------|-----|---------------------|
| Storage Account | Standard_LRS | ~¥300 |
| App Service Plan | B1 | ~¥2,000 |
| App Service | - | プランに含まれる |
| Managed Identity (User-Assigned) | - | 無料 |
| **合計** | | **~¥2,300/月** |

> 💡 無料枠を使う場合は、`main.parameters.json` の `appServiceSku` を `F1` に変更してください（制限あり）。

---

## 🔑 必要な Secret/設定

### GitHub Repository Secrets

- `COPILOT_FG_TOKEN`: Copilot が作業するための Fine-grained PAT

  [Fine-grained tokens](https://github.com/settings/tokens?type=beta) で作成し、以下を設定します。

  **Repository access**: `Public repositories` を選択

  **Repository permissions**:

  | Permission | 設定値 | 用途 |
  |-----------|--------|------|
  | **Copilot Requests** | Read-only | GitHub Actions 内で Copilot に作業を依頼する |

- `AZURE_CLIENT_ID`: Managed Identity のクライアント ID（デプロイ後に取得）
- `AZURE_TENANT_ID`: Azure テナント ID（デプロイ後に取得）
- `AZURE_SUBSCRIPTION_ID`: Azure サブスクリプション ID
- `AZURE_STORAGE_ACCOUNT_NAME`: Storage Account 名（デプロイ後に取得）

> 🔐 **キーレス認証**: Workload Identity Federation (OIDC) を使用するため、Storage の接続文字列やアクセスキーは不要です。

### Azure App Service Settings

- `GitHub__Token`: Web アプリからワークフローを操作するための Fine-grained PAT

  [Fine-grained tokens](https://github.com/settings/tokens?type=beta) で作成し、以下を設定します。

  **Repository access**: `All repositories` を選択

  **Repository permissions**:

  | Permission | 設定値 | 用途 |
  |-----------|--------|------|
  | **Actions** | **Read and write** | Web アプリから `workflow_dispatch` でジョブを登録・ステータス確認 |
  | **Metadata** | Read-only | 自動付与（Actions 追加時に自動で設定される） |

  > ⚠️ **Actions: Read and write がないと Web アプリの実行ボタンを押しても 403 エラー** になります。
- `AzureStorage__AccountName`: 自動設定済み
- `GitHub__Owner`, `GitHub__Repo`: 自動設定済み

---

## ✅ デプロイ後の確認

### 1. GitHub Actions を実行
```bash
gh workflow run copilot-poc.yml \
  --field prompt="Azure Cosmos DB の料金体系を調査" \
  --field output_format="Markdown"
```

### 2. Blob Storage を確認
```bash
# キーレス認証で確認（az login 済みであること）
az storage blob list \
  --account-name YOUR_STORAGE_ACCOUNT_NAME \
  --container-name copilot-outputs \
  --auth-mode login \
  --output table
```

### 3. Web アプリを開く
```bash
# デプロイ出力から APP_SERVICE_URL を取得
open "https://app-ghcp-dev-XXXXX.azurewebsites.net"
```

---

## 🧹 リソースの削除

```bash
# リソースグループごと削除（全リソース削除）
az group delete --name rg-copilot-agent-workspace --yes --no-wait
```

---

## 🔧 トラブルシューティング

### デプロイエラー: Storage account name already exists
→ `main.parameters.json` の `projectPrefix` を変更（例: `"ghcp"` → `"ghcp2"`）

### App Service が起動しない
→ ログを確認:
```bash
az webapp log tail --resource-group rg-copilot-agent-workspace --name YOUR_APP_NAME
```

### GitHub Actions が失敗する
→ Secret を確認:
```bash
gh secret list --repo YOUR_USERNAME/copilot-agent-workspace
```

### GitHub Actions: `AADSTS70021: No matching federated identity record found`
→ Bicep の `githubOwner`、`githubRepo`、`githubBranch` パラメータが実際のリポジトリと一致しているか確認:
```bash
# main.parameters.json を確認
cat main.parameters.json
# githubOwner / githubRepo / githubBranch が正しいこと
```

### Azure ポリシーによる `KeyBasedAuthenticationNotPermitted` エラー
→ このテンプレートはキーレス認証（Workload Identity Federation）を使用するため、このエラーは発生しません。古い `AZURE_STORAGE_CONNECTION_STRING` Secret が残っている場合は削除してください。

---

## 📚 詳細ドキュメント

- **Azure CLI 手順**: [README.md](README.md)
- **Copilot CLI 手順**: [SETUP_WITH_COPILOT_CLI.md](SETUP_WITH_COPILOT_CLI.md)
- **Bicep リファレンス**: [main.bicep](main.bicep) のコメントを参照
