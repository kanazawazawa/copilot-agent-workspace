
# Copilot Actionからの実行の準備作業

copilot-poc.ymlからの抜粋

> 前提:
>   1. Fine-grained PAT を作成（Permission: Copilot Requests）
>   2. リポジトリ Secret に COPILOT_FG_TOKEN として登録
>   3. Actions タブ → "Copilot SDK Runner" → "Run workflow" で手動実行



## Fine-grained PAT（Copilot Requests 権限）の作成手順

### 1. GitHub 設定画面へ移動
1. GitHub にログイン
2. 右上アイコン → **Settings**
3. 左サイドバー最下部 → **Developer settings**

---

### 2. Fine-grained Token 作成ページへ
1. **Personal access tokens** → **Fine-grained tokens**
2. **Generate new token** をクリック

---

### 3. トークン情報を入力

| 項目 | 設定値 |
|------|--------|
| Token name | 任意（例: `copilot-sdk-runner`） |
| Expiration | 最大 1 年（または組織ポリシーに従う） |
| Resource owner | 自分のアカウント or 組織 |
| Repository access | Public repositories |

---

### 4. Permissions（権限）設定

**Account permissions** セクションで以下を設定：

| Permission | 設定 |
|---|---|
| **Copilot Requests** | **Read and write** または **Read** |

> ワークフロー中の `COPILOT_GITHUB_TOKEN` として使用するため、Copilot API へのリクエスト権限が必要です。他の権限は最小限にとどめてください。

---

### 5. トークン生成・保存

1. **Generate token** をクリック
2. 表示されたトークン（`github_pat_...`）を**必ずコピー**（再表示不可）

---

### 6. リポジトリ Secret に登録

1. `yuyalush/copilot-agent-workspace` → **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret** をクリック
3. 以下を入力して保存：

| フィールド | 値 |
|---|---|
| Name | `COPILOT_FG_TOKEN` |
| Secret | 先ほどコピーしたトークン |

---

### 注意点
- 組織リソースにアクセスする場合、**組織オーナーの承認**が必要な場合があります
- トークンには**最小権限の原則**を適用してください
- 参考: [Managing your personal access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

---

## トラブルシューティング：Copilot Requests 権限が表示されない

**症状**: Repository Access で "Only select repositories" を選ぶと Permissions に "Copilot Requests" が出てこない。

**原因**: Copilot Requests は**特定リポジトリに紐づかないサービスレベルの権限**のため、"Only select repositories" では表示されない仕様。

**対処**: Repository Access を **"Public repositories"** に変更する。その上で Copilot Requests 以外の権限は付与しないことで最小権限を維持できる。

---

## トラブルシューティング：Git LFS エラー

**症状**: Copilot Agent が "Git LFS error" で停止する。

**原因**: リポジトリが Git LFS を使用している場合、Agent が LFS ファイルにアクセスできない。

**対処済み**:
1. ローカルで `git lfs install` を実行（Git LFS を有効化）
2. ワークフロー `.github/workflows/copilot-poc.yml` を更新：
   - `actions/checkout@v5` に `lfs: true` オプションを追加
   - チェックアウト後に `git lfs pull` ステップを追加

**再試行方法**: Pull Request にコメントで「Copilot to try again」と書く。

参考: [Copilot Coding Agent LFS Guide](https://gh.io/copilot-coding-agent-lfs)