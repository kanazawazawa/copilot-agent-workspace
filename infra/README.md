# Azure インフラストラクチャ セットアップ手順

このドキュメントは、Copilot Agent Workspace の Azure リソースをデプロイする手順を説明します。

---

## 📋 前提条件

### 必須ツール
- **Azure CLI**: [インストール手順](https://learn.microsoft.com/cli/azure/install-azure-cli)
- **Git**: バージョン管理
- **GitHub CLI** (推奨): GitHub 操作の自動化

### 必要な権限
- Azure サブスクリプションへの **Contributor** 以上の権限
- GitHub リポジトリへの **Admin** 権限（Secret 登録のため）

---

## 🏗️ デプロイされるリソース

| リソース | 用途 | SKU |
|---------|------|-----|
| **Storage Account** | GitHub Actions の成果物保存 | Standard_LRS |
| **Blob Container** | `copilot-outputs` コンテナ | - |
| **App Service Plan** | Web アプリのホスティングプラン | B1（変更可能） |
| **App Service** | Copilot SDK Runner 管理 UI | .NET 10 Blazor |
| **User-Assigned Managed Identity** | GitHub Actions と App Service の Azure 認証 | - |
| **Federated Credential** | GitHub Actions OIDC 信頼関係 | - |

> 🔐 **キーレス認証**: Storage Account のアクセスキーは無効（`allowSharedKeyAccess: false`）です。GitHub Actions は Workload Identity Federation (OIDC) 経由で Azure に認証します。

---

## 🚀 セットアップ手順

### ステップ 1: Azure へのログイン

```bash
# Azure にログイン
az login

# サブスクリプション一覧を表示
az account list --output table

# 使用するサブスクリプションを設定
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# 現在のサブスクリプションを確認
az account show --output table
```

---

### ステップ 2: リソースグループの作成

```bash
# 変数設定
RESOURCE_GROUP="rg-copilot-agent-workspace"
LOCATION="japaneast"

# リソースグループを作成
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# 作成確認
az group show --name $RESOURCE_GROUP --output table
```

---

### ステップ 3: パラメータファイルの準備

```bash
# テンプレートからパラメータファイルをコピー
cd infra
cp main.parameters.template.json main.parameters.json

# パラメータファイルを編集
code main.parameters.json
```

**編集内容**:
```json
{
  "parameters": {
    "projectPrefix": {
      "value": "ghcp"  // 3-10文字の英数字（小文字推奨）
    },
    "environment": {
      "value": "dev"  // dev, stg, prod のいずれか
    },
    "appServiceSku": {
      "value": "B1"  // F1（無料）, B1（Basic）, S1（Standard）
    },
    "githubOwner": {
      "value": "YOUR_GITHUB_USERNAME"  // ← 変更必須
    },
    "githubRepo": {
      "value": "copilot-agent-workspace"
    },
    "githubBranch": {
      "value": "master"  // ← OIDC 信頼関係を設定するブランチ名
    }
  }
}
```

> ⚠️ **`githubBranch` が重要**: Workload Identity Federation の Federated Credential に使用します。実際の GitHub リポジトリのデフォルトブランチ名と一致させてください。一致しないと GitHub Actions 実行時に `AADSTS70021` エラーになります。

> ⚠️ **注意**: GitHub PAT は Azure デプロイ後に App Service の設定で追加します。

---

### ステップ 4: Bicep テンプレートの検証

```bash
# Bicep テンプレートの構文チェック
az deployment group validate \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters main.parameters.json

# What-If 分析（実際のデプロイ前にプレビュー）
az deployment group what-if \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters main.parameters.json
```

---

### ステップ 5: Azure リソースのデプロイ

```bash
# デプロイ実行（5-10分程度）

# bash/Linux の場合:
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters main.parameters.json \
  --name "copilot-workspace-$(date +%Y%m%d-%H%M%S)"

# PowerShell の場合:
az deployment group create `
  --resource-group $RESOURCE_GROUP `
  --template-file main.bicep `
  --parameters main.parameters.json `
  --name "copilot-workspace-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# デプロイ完了後の出力値を取得
az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name "copilot-workspace-YYYYMMDD-HHMMSS" \
  --query properties.outputs
```

**重要な出力値**:
- `managedIdentityClientId`: GitHub Actions Secret `AZURE_CLIENT_ID` に登録
- `tenantId`: GitHub Actions Secret `AZURE_TENANT_ID` に登録
- `storageAccountName`: GitHub Actions Secret `AZURE_STORAGE_ACCOUNT_NAME` に登録
- `appServiceUrl`: Web アプリの URL

---

### ステップ 6: 出力値の保存

```bash
# デプロイ名を変数に設定（実際の名前に変更）
DEPLOYMENT_NAME="copilot-workspace-YYYYMMDD-HHMMSS"

# Managed Identity Client ID
MANAGED_IDENTITY_CLIENT_ID=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name $DEPLOYMENT_NAME \
  --query "properties.outputs.managedIdentityClientId.value" \
  --output tsv)

# Tenant ID
TENANT_ID=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name $DEPLOYMENT_NAME \
  --query "properties.outputs.tenantId.value" \
  --output tsv)

# Storage Account 名
STORAGE_ACCOUNT_NAME=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name $DEPLOYMENT_NAME \
  --query "properties.outputs.storageAccountName.value" \
  --output tsv)

# App Service URL
APP_SERVICE_URL=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name $DEPLOYMENT_NAME \
  --query "properties.outputs.appServiceUrl.value" \
  --output tsv)

# App Service 名
APP_SERVICE_NAME=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name $DEPLOYMENT_NAME \
  --query "properties.outputs.appServiceName.value" \
  --output tsv)

# Subscription ID
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

# 確認
echo "Managed Identity Client ID : $MANAGED_IDENTITY_CLIENT_ID"
echo "Tenant ID                  : $TENANT_ID"
echo "Storage Account Name       : $STORAGE_ACCOUNT_NAME"
echo "App Service URL            : $APP_SERVICE_URL"
echo "Subscription ID            : $SUBSCRIPTION_ID"
```

---

### ステップ 7: GitHub Secrets の登録

#### 方法 A: GitHub CLI を使用（推奨）

```bash
# GitHub にログイン
gh auth login

# Workload Identity Federation 用の 4つの Secret を登録
gh secret set AZURE_CLIENT_ID \
  --repo YOUR_GITHUB_USERNAME/copilot-agent-workspace \
  --body "$MANAGED_IDENTITY_CLIENT_ID"

gh secret set AZURE_TENANT_ID \
  --repo YOUR_GITHUB_USERNAME/copilot-agent-workspace \
  --body "$TENANT_ID"

gh secret set AZURE_SUBSCRIPTION_ID \
  --repo YOUR_GITHUB_USERNAME/copilot-agent-workspace \
  --body "$SUBSCRIPTION_ID"

gh secret set AZURE_STORAGE_ACCOUNT_NAME \
  --repo YOUR_GITHUB_USERNAME/copilot-agent-workspace \
  --body "$STORAGE_ACCOUNT_NAME"

# 登録確認
gh secret list --repo YOUR_GITHUB_USERNAME/copilot-agent-workspace
```

> 🔐 **キーレス認証**: 接続文字列やアクセスキーは不要です。GitHub Actions は OIDC トークンで直接 Azure に認証します。

#### 方法 B: GitHub Web UI を使用

1. リポジトリページを開く: `https://github.com/YOUR_USERNAME/copilot-agent-workspace`
2. **Settings** → **Secrets and variables** → **Actions**
3. **New repository secret** をクリックし、以下の 4つを登録：
   - `AZURE_CLIENT_ID`: Managed Identity の Client ID
   - `AZURE_TENANT_ID`: Azure テナント ID
   - `AZURE_SUBSCRIPTION_ID`: Azure サブスクリプション ID
   - `AZURE_STORAGE_ACCOUNT_NAME`: Storage Account 名

---

### ステップ 8: GitHub PAT の App Service への登録

#### PAT の作成と権限設定

[GitHub → Settings → Developer settings → Fine-grained tokens](https://github.com/settings/tokens?type=beta) で PAT を作成します。

**Repository access**: `All repositories` を選択

**Repository permissions**:

| Permission | 設定値 | 用途 |
|-----------|--------|------|
| **Actions** | **Read and write** | Web アプリから `workflow_dispatch` でジョブを登録・ステータス確認 |
| **Metadata** | Read-only | 自動付与（Actions 追加時に自動で設定される） |

> ⚠️ **Actions: Read and write がないと 403 エラー** になります。Web アプリの実行ボタンを押してもワークフローを起動できません。

```bash
# App Service 名を取得
APP_SERVICE_NAME=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name "copilot-workspace-YYYYMMDD-HHMMSS" \
  --query "properties.outputs.appServiceName.value" \
  --output tsv)

# GitHub PAT を App Service の設定に追加
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --settings GitHub__Token="YOUR_GITHUB_PAT_HERE"
```

> ⚠️ **セキュリティ**: PAT はコマンド履歴に残るため、Azure Portal から設定することを推奨します。

**Azure Portal での設定手順**:
1. [Azure Portal](https://portal.azure.com) にログイン
2. App Service を検索（名前: `app-ghcp-dev-XXXXX`）
3. **Settings** → **Environment variables**
4. **App settings** タブで `GitHub__Token` を探す
5. 値を編集して保存

---

### ステップ 9: App Service へのデプロイ

```bash
# webapp ディレクトリに移動
cd ../webapp

# .NET アプリをビルド
dotnet publish -c Release -o ./publish

# zip パッケージを作成（PowerShell 組み込みコマンド）
Compress-Archive -Path ./publish/* -DestinationPath ./webapp.zip -Force

# Azure App Service にデプロイ
az webapp deploy \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --src-path webapp.zip \
  --type zip

# デプロイ完了を確認
az webapp browse \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME
```

---

## ✅ 動作確認

### 1. GitHub Actions の実行

```bash
# GitHub Actions を手動実行
gh workflow run copilot-poc.yml \
  --repo YOUR_GITHUB_USERNAME/copilot-agent-workspace \
  --field prompt="Azure App Service の概要を調査してください" \
  --field output_format="Markdown" \
  --field language="Japanese"

# 実行状態を確認
gh run list --repo YOUR_GITHUB_USERNAME/copilot-agent-workspace --limit 5
```

### 2. Blob Storage の確認

```bash
# キーレス認証で Blob コンテナの内容を確認
# （az login 済みのユーザーに Storage Blob Data Reader 以上の権限が必要）
az storage blob list \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --container-name copilot-outputs \
  --auth-mode login \
  --output table
```

### 3. Web アプリの確認

```bash
# Web アプリを開く
open $APP_SERVICE_URL
# または
start $APP_SERVICE_URL  # Windows
```

---

## 🔧 トラブルシューティング

### デプロイエラー: "Storage account name already exists"

**原因**: ストレージアカウント名が他のユーザーと重複している。

**対処法**: `main.parameters.json` の `projectPrefix` を変更する。
```json
{
  "projectPrefix": {
    "value": "ghcp2"  // 別の値に変更
  }
}
```

---

### App Service が起動しない

**確認手順**:
```bash
# ログストリームを確認
az webapp log tail \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME

# 最新のログをダウンロード
az webapp log download \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --log-file app-logs.zip
```

---

### GitHub Actions が Blob Storage にアップロードできない

**確認項目**:
1. 4つの Secret が登録されているか
   ```bash
   gh secret list --repo YOUR_GITHUB_USERNAME/copilot-agent-workspace
   # AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID, AZURE_STORAGE_ACCOUNT_NAME があること
   ```

2. `AADSTS70021: No matching federated identity record found` の場合
   - Bicep の `githubOwner`、`githubRepo`、`githubBranch` が実際のリポジトリと一致しているか確認
   - 一致しない場合は Bicep を修正して再デプロイ

3. `KeyBasedAuthenticationNotPermitted` の場合
   - 旧 Secret `AZURE_STORAGE_CONNECTION_STRING` がワークフローに残っていないか確認して削除する

4. ワークフローログを確認
   ```bash
   gh run view --repo YOUR_GITHUB_USERNAME/copilot-agent-workspace --log-failed
   ```

---

## 🧹 リソースの削除（クリーンアップ）

### 方法 1: リソースグループごと削除（最速・推奨）

```bash
# リソースグループを削除（内の全リソースがまとめて削除されます）
az group delete \
  --name $RESOURCE_GROUP \
  --yes \
  --no-wait

# 削除状態を確認（「error」になれば削除完了）
az group show --name $RESOURCE_GROUP --output table 2>&1
```

> ⚠️ `--no-wait` を付けるとバックグラウンドで削除が始まります。削除完了を待つ場合は `--no-wait` を検してください（5【15分程度）。

---

### 方法 2: リソースグループごと削除（削除内容を確認してから削除）

```bash
# 削除対象のリソースを一覧表示
az resource list \
  --resource-group $RESOURCE_GROUP \
  --output table

# 内容を確認したら削除実行
az group delete \
  --name $RESOURCE_GROUP \
  --yes
```

---

### 方法 3: リソースグループは残して個別リソースだけ削除

```bash
# 順番: Storage Account → Managed Identity → App Service → App Service Plan

# 1. App Service を削除
az webapp delete \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME

# 2. App Service Plan を削除
az appservice plan delete \
  --resource-group $RESOURCE_GROUP \
  --name "plan-${APP_SERVICE_NAME#app-}" \
  --yes

# 3. Storage Account を削除
az storage account delete \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT_NAME \
  --yes

# 4. Managed Identity を削除
az identity delete \
  --resource-group $RESOURCE_GROUP \
  --name "id-${APP_SERVICE_NAME#app-}"
```

---

### 方法 4: GitHub Secrets のクリーンアップ

Azure リソース削除後は GitHub Secrets も削除しておくことを推奨します。

```bash
# OIDC 用 Secrets を削除
gh secret delete AZURE_CLIENT_ID \
  --repo YOUR_GITHUB_USERNAME/copilot-agent-workspace

gh secret delete AZURE_TENANT_ID \
  --repo YOUR_GITHUB_USERNAME/copilot-agent-workspace

gh secret delete AZURE_SUBSCRIPTION_ID \
  --repo YOUR_GITHUB_USERNAME/copilot-agent-workspace

gh secret delete AZURE_STORAGE_ACCOUNT_NAME \
  --repo YOUR_GITHUB_USERNAME/copilot-agent-workspace

# 削除確認
gh secret list --repo YOUR_GITHUB_USERNAME/copilot-agent-workspace
```

---

## 📚 参考リンク

- [Azure CLI リファレンス](https://learn.microsoft.com/cli/azure/)
- [Bicep ドキュメント](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [App Service ドキュメント](https://learn.microsoft.com/azure/app-service/)
- [Azure Storage ドキュメント](https://learn.microsoft.com/azure/storage/)
- [GitHub CLI ドキュメント](https://cli.github.com/)
