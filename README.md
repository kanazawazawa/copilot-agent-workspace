# エージェント環境 セットアップガイド

## この環境について

**調査業務 & ドキュメント作成** に特化した GitHub Copilot エージェント環境です。
[microsoft/skills](https://github.com/microsoft/skills) や [github/awesome-copilot](https://github.com/github/awesome-copilot) のパターンを参考に構築しています。

---

## ディレクトリ構成

```
ghcpskills/
├── .github/
│   ├── copilot-instructions.md                  # Copilot 共通ルール（常に適用）
│   ├── skills/                                  # タスク別の専門知識
│   │   ├── ms-learn-research/SKILL.md           # MS Learn 調査
│   │   ├── customer-research/SKILL.md           # 顧客情報調査
│   │   └── slide-creator/SKILL.md            # SVGスライド→PPTX変換
│   └── instructions/                            # ファイルパターン別ルール
│       ├── markdown-quality.instructions.md     # *.md 向け
│       └── research-quality.instructions.md     # 調査ドキュメント向け
├── .gitignore                                   # Git 除外設定
├── .vscode/
│   └── mcp.json                                 # MCP サーバー設定
├── scripts/
│   └── svg2pptx.py                              # SVG→PPTX 変換（実行用）
├── AGENTS.md                                    # 全体方針・原則（常に適用）
├── LICENSE                                      # MIT License
└── README.md                                    # ← このファイル
```

---

## 各ファイルの役割と使い分け

### AGENTS.md（プロジェクト全体の方針）

- **いつ効くか:** Copilot のすべてのインタラクション
- **何を書くか:** このプロジェクト固有の原則、ワークフロー、禁止事項
- **元ネタ:** [microsoft/skills の Agents.md](https://github.com/microsoft/skills/blob/main/Agents.md)

### .github/copilot-instructions.md（Copilot 共通ルール）

- **いつ効くか:** このワークスペースで Copilot を使うとき常に
- **何を書くか:** 言語設定、回答スタイル、共通フォーマット
- **違い:** AGENTS.md がプロジェクト固有なのに対し、こちらは Copilot の振る舞いルール

### .github/skills/（スキル）

- **いつ効くか:** 関連するタスクをリクエストしたとき（トリガーワードで発動）
- **何を書くか:** 特定タスクの手順、テンプレート、ルール
- **元ネタ:** [microsoft/skills のスキル構造](https://github.com/microsoft/skills/tree/main/.github/skills)、[awesome-copilot の skills/](https://github.com/github/awesome-copilot/tree/main/skills)

### .github/instructions/（インストラクション）

- **いつ効くか:** `applyTo` で指定したファイルパターンの編集時に自動適用
- **何を書くか:** そのファイル種別固有のルール・品質基準
- **元ネタ:** [awesome-copilot の instructions/](https://github.com/github/awesome-copilot/tree/main/instructions)

### .vscode/mcp.json（MCP サーバー設定）

- **いつ効くか:** Copilot がツールとして使える外部サービスの設定
- **何を書くか:** MCP サーバーの接続情報
- **元ネタ:** [microsoft/skills の mcp.json](https://github.com/microsoft/skills/blob/main/.vscode/mcp.json)

---

## 設定済み MCP サーバー

| サーバー | 用途 | 種類 |
|----------|------|------|
| `microsoft-docs` | MS Learn 公式ドキュメント検索・取得 | HTTP |
| `context7` | ドキュメントのセマンティック検索 | stdio |
| `deepwiki` | GitHub リポジトリの質問応答 | HTTP |
| `sequentialthinking` | 複雑な問題の段階的推論 | stdio |
| `memory` | セッション間の記憶保持 | stdio |
| `github` | GitHub API 操作 | HTTP |

---

## 使い方の例

### 例1: Azure サービスの調査
```
「Azure Functions と Azure Container Apps の違いを調べて、
 サーバーレスの観点で比較表を作成して」
```
→ `ms-learn-research` スキルが発動 → microsoft-docs MCP で検索 → 比較表作成

### 例2: 顧客向け提案書の作成
```
「〇〇社向けに Azure AI サービスの提案スライドを10枚で作って」
```
→ `slide-creator` スキルが発動 → アウトライン提示 → 承認後に SVG スライド生成 → PPTX 変換

### 例3: 業界動向の調査
```
「製造業の DX 動向と Azure の活用事例を調べて」
```
→ `customer-research` スキルが発動 → 調査サマリー作成

---

## 育て方: 新しいスキルの追加

### 1. スキルフォルダを作成
```
.github/skills/<skill-name>/SKILL.md
```

### 2. フロントマターを書く
```yaml
---
name: my-new-skill
description: 'このスキルの説明（10-1024文字）'
---
```

### 3. 本文に手順・ルール・テンプレートを記載

### 4. AGENTS.md のスキル表に追加

---

## 参考リンク

- [microsoft/skills](https://github.com/microsoft/skills) — Azure SDK 向けスキル集（構成の参考元）
- [github/awesome-copilot](https://github.com/github/awesome-copilot) — コミュニティ製 Copilot カスタマイズ集（構成の参考元）
- [VS Code Copilot Customization](https://code.visualstudio.com/docs/copilot/copilot-customization) — 公式ドキュメント
- [Agent Skills 仕様](https://agentskills.io/specification) — スキルの標準仕様

---

## 成長ロードマップ

- [x] Phase 1: 調査 & ドキュメント作成（**今ここ**）
- [ ] Phase 2: コード生成 & レビュー支援
- [ ] Phase 3: Azure / クラウド開発支援
- [ ] Phase 4: CI/CD & テスト自動化

---

## 依存ライブラリ

| ライブラリ | 用途 | ライセンス |
|-----------|------|-----------|
| [python-pptx](https://github.com/scanny/python-pptx) | SVG → PPTX 変換（`svg2pptx.py`） | MIT |
| [lxml](https://github.com/lxml/lxml) | SVG の XML パース | BSD |
