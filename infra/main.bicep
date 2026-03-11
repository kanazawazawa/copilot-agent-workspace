// =============================================================================
// Copilot Agent Workspace - Azure Infrastructure
// =============================================================================
// このテンプレートは以下のリソースをデプロイします：
// 1. Storage Account - GitHub Actions の成果物保存用（キーレス認証）
// 2. User-Assigned Managed Identity - GitHub Actions OIDC 用
// 3. Federated Identity Credential - GitHub Actions OIDC 連携
// 4. Role Assignment - Storage Blob Data Contributor（GitHub Actions + App Service 用）
// 5. App Service Plan - Blazor Web アプリホスティング用
// 6. App Service - Copilot SDK Runner の管理 Web アプリ
// =============================================================================

@description('デプロイ先の Azure リージョン')
param location string = resourceGroup().location

@description('リソース名のプレフィックス（3-10文字の英数字）')
@minLength(3)
@maxLength(10)
param projectPrefix string

@description('環境名（dev, stg, prod など）')
@allowed([
  'dev'
  'stg'
  'prod'
])
param environment string = 'dev'

@description('App Service の SKU')
@allowed([
  'F1'  // Free
  'B1'  // Basic
  'S1'  // Standard
  'P1v3' // Premium v3
])
param appServiceSku string = 'B1'

@description('GitHub リポジトリオーナー名')
param githubOwner string

@description('GitHub リポジトリ名')
param githubRepo string

@description('GitHub ブランチ名（Federated Credential の subject に使用）')
param githubBranch string = 'master'

@description('GitHub PAT（Personal Access Token）- デプロイ後に App Settings で設定')
@secure()
param githubToken string = ''

// =============================================================================
// 変数定義
// =============================================================================

var resourceSuffix = '${projectPrefix}-${environment}-${uniqueString(resourceGroup().id)}'
var storageAccountName = replace('st${resourceSuffix}', '-', '') // ハイフン除去（Storage Account 命名規則）
var managedIdentityName = 'id-${resourceSuffix}'
var appServicePlanName = 'asp-${resourceSuffix}'
var appServiceName = 'app-${resourceSuffix}'
var containerName = 'copilot-outputs'

// Storage Blob Data Contributor ロール定義 ID（Azure 組み込みロール）
var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

// =============================================================================
// Storage Account - Copilot SDK Runner の成果物保存用（キーレス認証）
// =============================================================================

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false  // キーレス認証のみ許可
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
  }

  resource blobService 'blobServices' = {
    name: 'default'

    resource container 'containers' = {
      name: containerName
      properties: {
        publicAccess: 'None'
      }
    }
  }
}

// =============================================================================
// User-Assigned Managed Identity - GitHub Actions OIDC 認証用
// =============================================================================

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: managedIdentityName
  location: location
}

// Federated Identity Credential: GitHub Actions OIDC との信頼関係
// subject: repo:{owner}/{repo}:ref:refs/heads/{branch}
resource federatedCredential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-07-31-preview' = {
  name: 'github-actions-oidc'
  parent: managedIdentity
  properties: {
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:${githubOwner}/${githubRepo}:ref:refs/heads/${githubBranch}'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}

// =============================================================================
// Role Assignment - GitHub Actions (UA-MI) に Storage Blob Data Contributor 付与
// =============================================================================

resource roleAssignmentGitHubActions 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, managedIdentity.id, storageBlobDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// =============================================================================
// App Service Plan - Blazor Web アプリホスティング用
// =============================================================================

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServiceSku
  }
  kind: 'linux'
  properties: {
    reserved: true  // Linux プラン必須
  }
}

// =============================================================================
// App Service - Copilot SDK Runner 管理 Web アプリ（System-Assigned MI）
// =============================================================================

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: appServiceName
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'  // DefaultAzureCredential で自動認証
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|10.0'
      alwaysOn: appServiceSku != 'F1'
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: environment == 'prod' ? 'Production' : 'Development'
        }
        {
          name: 'AzureStorage__AccountName'
          value: storageAccount.name
        }
        {
          name: 'AzureStorage__ContainerName'
          value: containerName
        }
        {
          name: 'GitHub__Owner'
          value: githubOwner
        }
        {
          name: 'GitHub__Repo'
          value: githubRepo
        }
        {
          name: 'GitHub__Token'
          value: githubToken
        }
        {
          name: 'GitHub__WorkflowFileName'
          value: 'copilot-poc.yml'
        }
      ]
    }
  }
}

// Role Assignment - App Service (System-Assigned MI) に Storage Blob Data Contributor 付与
resource roleAssignmentAppService 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, appService.id, storageBlobDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: appService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// =============================================================================
// 出力値 - デプロイ後に必要な情報
// =============================================================================

@description('Storage Account 名（GitHub Actions Secret: AZURE_STORAGE_ACCOUNT_NAME 用）')
output storageAccountName string = storageAccount.name

@description('Blob Container 名')
output containerName string = containerName

@description('App Service 名')
output appServiceName string = appService.name

@description('App Service URL')
output appServiceUrl string = 'https://${appService.properties.defaultHostName}'

@description('GitHub Actions OIDC 用 Managed Identity の Client ID（GitHub Actions Secret: AZURE_CLIENT_ID 用）')
output managedIdentityClientId string = managedIdentity.properties.clientId

@description('Azure Tenant ID（GitHub Actions Secret: AZURE_TENANT_ID 用）')
output tenantId string = tenant().tenantId

@description('App Service の Managed Identity Principal ID')
output appServicePrincipalId string = appService.identity.principalId
