# Copilot CLI を使った Azure デプロイ手順

このドキュメントは、GitHub Copilot CLI を使用して対話的に Azure リソースをデプロイする方法を説明します。

---

## 📋 前提条件

### 必須ツール
- **Azure CLI**: [インストール手順](https://learn.microsoft.com/cli/azure/install-azure-cli)
- **GitHub Copilot CLI**: 以下のコマンドでインストール
  ```bash
  npm install -g @github/copilot
  ```
- **Git**: バージョン管理

### 必要な権限
- Azure サブスクリプションへの **Contributor** 以上の権限
- GitHub Copilot の有効なサブスクリプション

---

## 🚀 Copilot CLI を使ったデプロイ

### ステップ 1: Copilot CLI のセットアップ

```bash
# Copilot CLI のバージョン確認
copilot --version

# 認証（初回のみ）
copilot --help
# ブラウザが開いて GitHub 認証が求められます
```

---

### ステップ 2: Azure へのログイン

Copilot CLI に以下のように依頼します：

```bash
copilot explain "Azure に az login でログインし、サブスクリプションを確認する方法"
```

Copilot が提案するコマンドを実行：
```bash
az login
az account list --output table
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

---

### ステップ 3: リソースグループの作成

Copilot に依頼：
```bash
copilot "Azure でリソースグループ rg-copilot-agent-workspace を Japan East にデプロイする Azure CLI コマンドを生成して"
```

提案されたコマンドを実行：
```bash
az group create --name rg-copilot-agent-workspace --location japaneast
```

---

### ステップ 4: パラメータファイルの準備

```bash
# infra ディレクトリに移動
cd infra

# テンプレートから実際のパラメータファイルをコピー
cp main.parameters.template.json main.parameters.json

# Copilot に編集を依頼
copilot "main.parameters.json の githubOwner を私の GitHub ユーザー名に変更するコマンドを教えて"
```

または直接編集：
```bash
code main.parameters.json
```

**編集内容例**:
```json
{
  "parameters": {
    "projectPrefix": { "value": "ghcp" },
    "environment": { "value": "dev" },
    "appServiceSku": { "value": "B1" },
    "githubOwner": { "value": "YOUR_GITHUB_USERNAME" },  // ← 変更
    "githubRepo": { "value": "copilot-agent-workspace" },
    "githubBranch": { "value": "master" }  // ← OIDC フェデレーション対象ブランチ
  }
}
```

> ⚠️ **`githubBranch` が重要**: Workload Identity Federation の信頼関係に使用します。ブランチ名が実際の GitHub リポジトリと一致しないと `AADSTS70021` エラーになります。

---

### ステップ 5: Bicep デプロイの検証

Copilot に依頼：
```bash
copilot "main.bicep を main.parameters.json で検証する Azure CLI コマンド"
```

提案されたコマンドを実行：
```bash
az deployment group validate \
  --resource-group rg-copilot-agent-workspace \
  --template-file main.bicep \
  --parameters main.parameters.json
```

What-If 分析も実行：
```bash
copilot "Bicep デプロイの What-If 分析を実行するコマンド"
```

---

### ステップ 6: Bicep デプロイの実行

Copilot に依頼：
```bash
copilot "main.bicep を rg-copilot-agent-workspace にデプロイする Azure CLI コマンドを生成して。デプロイ名には現在のタイムスタンプを含めて"
```

提案されたコマンドを実行：

**bash/Linux の場合**:
```bash
az deployment group create \
  --resource-group rg-copilot-agent-workspace \
  --template-file main.bicep \
  --parameters main.parameters.json \
  --name "copilot-workspace-$(date +%Y%m%d-%H%M%S)"
```

**PowerShell の場合**:
```powershell
az deployment group create `
  --resource-group rg-copilot-agent-workspace `
  --template-file main.bicep `
  --parameters main.parameters.json `
  --name "copilot-workspace-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
```

> ⏱️ デプロイには 5-10 分程度かかります。

---

### ステップ 7: デプロイ結果の取得

Copilot に依頼：
```bash
copilot "最新の Azure デプロイの出力値を JSON 形式で取得するコマンド"
```

または直接実行：
```bash
# 最新のデプロイ名を取得
DEPLOYMENT_NAME=$(az deployment group list \
  --resource-group rg-copilot-agent-workspace \
  --query "[0].name" \
  --output tsv)

# 出力値を取得
az deployment group show \
  --resource-group rg-copilot-agent-workspace \
  --name $DEPLOYMENT_NAME \
  --query properties.outputs \
  --output json
```

**重要な出力値**:
- `managedIdentityClientId`: GitHub Actions Secret `AZURE_CLIENT_ID` に登録
- `tenantId`: GitHub Actions Secret `AZURE_TENANT_ID` に登録
- `storageAccountName`: GitHub Actions Secret `AZURE_STORAGE_ACCOUNT_NAME` に登録
- `appServiceUrl`: Web アプリの URL

これらの値をメモまたは環境変数に保存（bash の場合）:
```bash
MANAGED_IDENTITY_CLIENT_ID=$(az deployment group show \
  --resource-group rg-copilot-agent-workspace \
  --name $DEPLOYMENT_NAME \
  --query "properties.outputs.managedIdentityClientId.value" \
  --output tsv)

TENANT_ID=$(az deployment group show \
  --resource-group rg-copilot-agent-workspace \
  --name $DEPLOYMENT_NAME \
  --query "properties.outputs.tenantId.value" \
  --output tsv)

STORAGE_ACCOUNT_NAME=$(az deployment group show \
  --resource-group rg-copilot-agent-workspace \
  --name $DEPLOYMENT_NAME \
  --query "properties.outputs.storageAccountName.value" \
  --output tsv)

APP_SERVICE_URL=$(az deployment group show \
  --resource-group rg-copilot-agent-workspace \
  --name $DEPLOYMENT_NAME \
  --query "properties.outputs.appServiceUrl.value" \
  --output tsv)

APP_SERVICE_NAME=$(az deployment group show \
  --resource-group rg-copilot-agent-workspace \
  --name $DEPLOYMENT_NAME \
  --query "properties.outputs.appServiceName.value" \
  --output tsv)

SUBSCRIPTION_ID=$(az account show --query id --output tsv)

echo "✅ 環境変数に保存しました"
echo "Managed Identity Client ID: $MANAGED_IDENTITY_CLIENT_ID"
echo "Tenant ID: $TENANT_ID"
echo "Storage Account Name: $STORAGE_ACCOUNT_NAME"
echo "App Service URL: $APP_SERVICE_URL"
```

---

### ステップ 8: GitHub Secrets の登録

#### GitHub CLI を使用

Copilot に依頼：
```bash
copilot "GitHub リポジトリに複数の Secret を gh コマンドで一括登録する方法"
```

提案されたコマンドを実行（環境変数を使用）：
```bash
# Workload Identity Federation 用の 4つの Secret を登録
gh secret set AZURE_CLIENT_ID \
  --repo kanazawazawa/copilot-agent-workspace \
  --body "$MANAGED_IDENTITY_CLIENT_ID"

gh secret set AZURE_TENANT_ID \
  --repo kanazawazawa/copilot-agent-workspace \
  --body "$TENANT_ID"

gh secret set AZURE_SUBSCRIPTION_ID \
  --repo kanazawazawa/copilot-agent-workspace \
  --body "$SUBSCRIPTION_ID"

gh secret set AZURE_STORAGE_ACCOUNT_NAME \
  --repo kanazawazawa/copilot-agent-workspace \
  --body "$STORAGE_ACCOUNT_NAME"

# 旧 Secret が残っている場合は削除
gh secret delete AZURE_STORAGE_CONNECTION_STRING \
  --repo kanazawazawa/copilot-agent-workspace 2>/dev/null || true

# 登録確認
gh secret list --repo kanazawazawa/copilot-agent-workspace
```

> 🔐 **どうして接続文字列が不要か**: Workload Identity Federation (OIDC) を使うことで、GitHub Actions が直接 Azure に信頼されたトークンで認証します。Storage のアクセスキーや接続文字列は一切使いません。

#### Web UI を使用する場合

Copilot に依頼：
```bash
copilot "GitHub リポジトリに Secret を Web UI で登録する手順を教えて"
```

---

### ステップ 9: GitHub PAT を App Service に登録

#### PAT の作成と権限設定

[GitHub → Settings → Developer settings → Fine-grained tokens](https://github.com/settings/tokens?type=beta) で PAT を作成します。

**Repository access**: `All repositories` を選択

**Repository permissions**:

| Permission | 設定値 | 用途 |
|-----------|--------|------|
| **Actions** | **Read and write** | Web アプリから `workflow_dispatch` でジョブを登録・ステータス確認 |
| **Metadata** | Read-only | 自動付与（Actions 追加時に自動で設定される） |

> ⚠️ **Actions: Read and write がないと 403 エラー** になります。Web アプリの実行ボタンを押してもワークフローを起動できません。

Copilot に依頼：
```bash
copilot "Azure App Service の設定に GitHub__Token という App Setting を追加する Azure CLI コマンド"
```

提案されたコマンド（セキュリティのため、値は手動で入力）：
```bash
az webapp config appsettings set \
  --resource-group rg-copilot-agent-workspace \
  --name $APP_SERVICE_NAME \
  --settings GitHub__Token="ghp_YOUR_GITHUB_PERSONAL_ACCESS_TOKEN"
```

> ⚠️ **推奨**: Azure Portal から設定する方がセキュアです。

**Azure Portal での手順**:
1. [Azure Portal](https://portal.azure.com) にログイン
2. App Service `$APP_SERVICE_NAME` を検索
3. **Settings** → **Environment variables**
4. `GitHub__Token` の値を編集して保存

---

### ステップ 10: Web アプリのデプロイ

Copilot に依頼：
```bash
copilot ".NET Blazor アプリを Azure App Service にデプロイする手順を教えて。webapp ディレクトリからビルドして zip でデプロイする方法で"
```

提案されたコマンドを実行：
```bash
# webapp ディレクトリに移動
cd ../webapp

# ビルド
dotnet publish -c Release -o ./publish

# zip パッケージ作成
cd publish
zip -r ../webapp.zip .
cd ..

# デプロイ
az webapp deployment source config-zip \
  --resource-group rg-copilot-agent-workspace \
  --name $APP_SERVICE_NAME \
  --src webapp.zip

# Web アプリを開く
az webapp browse \
  --resource-group rg-copilot-agent-workspace \
  --name $APP_SERVICE_NAME
```

---

## ✅ 動作確認

### GitHub Actions の実行

Copilot に依頼：
```bash
copilot "GitHub Actions ワークフロー copilot-poc.yml を手動実行する gh コマンド"
```

提案されたコマンドを実行：
```bash
gh workflow run copilot-poc.yml \
  --repo kanazawazawa/copilot-agent-workspace \
  --field prompt="Azure Cosmos DB の料金体系を調査してください" \
  --field output_format="Markdown" \
  --field language="Japanese"

# 実行状態を確認
gh run list --repo kanazawazawa/copilot-agent-workspace --limit 5

# 最新の実行ログを表示
gh run view --repo kanazawazawa/copilot-agent-workspace --log
```

### Blob Storage の確認

Copilot に依頼：
```bash
copilot "Azure Blob Storage の copilot-outputs コンテナの内容をキーレス認証で一覧表示する Azure CLI コマンド"
```

提案されたコマンドを実行：
```bash
# キーレス認証（az login 済みの ID に Storage Blob Data Reader 権限が必要）
az storage blob list \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --container-name copilot-outputs \
  --auth-mode login \
  --output table
```

---

## 🎯 Copilot CLI の活用ヒント

### コマンド生成の依頼例

1. **複雑な Azure CLI コマンド**:
   ```bash
   copilot "App Service のすべてのログを過去 24 時間分取得する方法"
   ```

2. **トラブルシューティング**:
   ```bash
   copilot "Azure App Service が起動しない原因を調査する方法"
   ```

3. **コスト確認**:
   ```bash
   copilot "リソースグループ rg-copilot-agent-workspace の今月の Azure 利用料金を確認するコマンド"
   ```

4. **リソース削除**:
   ```bash
   copilot "Azure リソースグループを削除するコマンドと、削除される内容の確認方法"
   ```

---

## 🔧 トラブルシューティング

何か問題が発生した場合は、Copilot に直接質問できます：

```bash
copilot "Azure デプロイで 'StorageAccountAlreadyExists' エラーが出た場合の対処法"
```

```bash
copilot "GitHub Actions が Blob Storage にアップロードできない原因を調査する方法"
```

```bash
copilot "App Service のログストリームをリアルタイムで確認するコマンド"
```

---

## 📚 参考リンク

- [GitHub Copilot CLI ドキュメント](https://docs.github.com/copilot/using-github-copilot/using-github-copilot-in-the-command-line)
- [Azure CLI リファレンス](https://learn.microsoft.com/cli/azure/)
- [Azure Bicep ドキュメント](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
