# AGENTS.md — Copilot エージェント環境

GitHub Copilot を「調査アシスタント＆ドキュメント作成パートナー」として
活用するためのエージェント環境です。

---

## プロジェクト概要

```
├── .github/
│   ├── copilot-instructions.md   # Copilot 全体に適用される共通ルール
│   ├── skills/                    # タスク別の専門知識パッケージ
│   │   ├── ms-learn-research/     # MS Learn 調査スキル
│   │   ├── customer-research/     # 顧客情報調査スキル
│   │   └── slide-creator/         # SVGスライド→PPTX変換
│   └── instructions/              # ファイルパターン別のルール
├── .vscode/
│   └── mcp.json                   # MCP サーバー設定
├── output/                        # ← 成果物の出力先（※後述）
│   ├── research/                  #   調査結果
│   ├── documents/                 #   提案書・報告書
│   ├── slides/                    #   SVG スライド + PPTX
│   └── customers/                 #   顧客調査
├── scripts/                       # ユーティリティスクリプト
├── AGENTS.md                      # ← このファイル（全体方針）
└── README.md                      # セットアップガイド
```

---

## 出力ディレクトリ構造とファイル命名規則

### ディレクトリ構造

すべての成果物は `output/` 配下に種類別で保存する。

```
output/
├── research/                 # 調査結果（MS Learn、技術調査）
│   └── YYYY-MM-DD_HHmmss_テーマ名/
│       └── report.md         # 調査結果本体
├── customers/                # 顧客情報調査
│   └── 企業名/
│       ├── profile.md        # 最新の企業概要
│       └── YYYY-MM-DD_HHmmss_調査テーマ.md
├── documents/                # 提案書・報告書・議事録
│   └── YYYY-MM-DD_HHmmss_ドキュメント名/
│       └── document.md       # ドキュメント本体
└── slides/                   # SVG スライド → PPTX
    └── YYYY-MM-DD_HHmmss_スライド名/
        ├── slide01.svg
        ├── slide02.svg
        ├── ...
        └── output.pptx       # 変換後の PPTX
```

### ファイル命名規則

| ルール | 例 |
|--------|-----|
| 日時プレフィックス `YYYY-MM-DD_HHmmss` | `2026-03-03_143052_cosmos-db-比較/` |
| 日本語OK（スペースは使わない） | `顧客A_初回提案.md` ○ / `顧客A 初回提案.md` ✗ |
| 区切りはハイフン `-` またはアンダースコア `_` | `azure-functions_料金比較.md` |
| 主要ファイルは用途別の名前にする | `report.md`（調査）/ `profile.md`（顧客）/ `document.md`（提案書等） |
| SVG は `slide01.svg` 〜 連番 | `slide01.svg`, `slide02.svg`, ... |
| PPTX は `output.pptx` またはテーマ名 | `output.pptx`, `顧客提案_v1.pptx` |

### 重複回避

フォルダ名に時分秒（`HHmmss`）を含めることで自然に一意になる。
同日・同テーマでも実行時刻が異なれば別フォルダになるため、サフィックス管理は不要。

```
output/slides/2026-03-03_143052_テーマ名/   ← 1回目（14:30:52）
output/slides/2026-03-03_153210_テーマ名/   ← 2回目（15:32:10）
```

- 既存ファイルは絶対に上書き・削除しない

### なぜ Markdown がメインか

- **再利用性**: 他のドキュメントにコピペ・引用しやすい
- **検索性**: テキストベースなので全文検索できる
- **差分管理**: Git で変更履歴を追跡できる
- **変換可能**: Markdown → SVG → PPTX / HTML / PDF
- **Copilot との相性**: テキストなので生成・編集が得意

---

## コア原則

### 1. 調べてから動く

- 推測で回答しない。必ず情報源を確認する
- MS Learn、公式ドキュメント、MCP サーバーを使って最新情報を取得する
- 情報源の URL を必ず添える

### 2. シンプルに、構造的に

- 箇条書き・表・見出しを活用し、冗長な文章を避ける
- 回答は日本語で行う
- 聞かれたことに答える。余計な装飾をしない

### 3. 段階的に深掘りする

- 最初に概要を示し、ユーザーの関心に応じて詳細を展開する
- 1回で全部出さず、対話的に進める

### 4. アウトプットの品質

- ドキュメントはそのまま使えるクオリティを目指す
- 図表・Mermaid ダイアグラムを積極的に使う
- PowerPoint向けの場合、スライドごとの構成を明示する

---

## Skills の使い方

Skills は `.github/skills/` にあるドメイン知識パッケージです。

| スキル名 | 用途 | トリガーワード |
|-----------|------|---------------|
| `ms-learn-research` | MS Learn の公式ドキュメント調査 | 「MS Learn」「公式ドキュメント」「Azure の仕様」 |
| `customer-research` | 顧客情報・業界・事例の調査 | 「顧客情報」「事例」「業界調査」 |
| `slide-creator` | SVGスライド→PPTX変換 | 「PPT作成」「スライド」「SVGスライド」「PPTX」 |

**重要:** 必要なスキルだけ読み込む。全部読み込むとコンテキストが薄まる。

---

## MCP サーバー

| MCP | 用途 |
|-----|------|
| `microsoft-docs` | MS Learn 公式ドキュメント検索 |
| `context7` | ドキュメントのセマンティック検索 |
| `deepwiki` | GitHub リポジトリの質問応答 |
| `sequentialthinking` | 複雑な問題の段階的推論 |
| `memory` | セッション間の記憶保持 |
| `github` | GitHub API 操作（Issue, PR 等） |

---

## ワークフロー例

### 調査タスク
1. ユーザーの質問を明確化（何を、なぜ、どの深さで）
2. MS Learn MCP で公式情報を検索
3. 必要に応じて Web ページを取得して詳細確認
4. 日本語で構造的にまとめる（情報源 URL 付き）

### ドキュメント作成タスク
1. 目的・対象読者・ページ数を確認
2. アウトライン（構成案）を先に提示
3. 承認後、スライドごと／セクションごとに内容を作成
4. Mermaid 図やテーブルで視覚的に補強

### SVG → PPTX スライド作成タスク
1. 目的・対象読者・ページ数を確認
2. アウトライン（構成案）を先に提示
3. 承認後、スライドごとに SVG (960x540) を生成
4. `python scripts/svg2pptx.py slides/ output.pptx` で PPTX に変換
5. PowerPoint で微調整（テキスト編集・色変更・アニメーション追加可能）

---

## 育て方ガイド

このエージェント環境は徐々に拡張していくものです。

### 新しいスキルを追加するには
1. `.github/skills/<skill-name>/SKILL.md` を作成
2. YAML フロントマター（`name`, `description`）を書く
3. マークダウン本文に手順・ルール・パターンを記載

### 新しい Instructions を追加するには
1. `.github/instructions/<name>.instructions.md` を作成
2. `applyTo` でどのファイルに適用するか指定
3. そのファイル種別固有のルールを記載

### 成長ロードマップ
- [x] Phase 1: 調査 & ドキュメント作成（今ここ）
- [ ] Phase 2: コード生成 & レビュー支援
- [ ] Phase 3: Azure / クラウド開発支援
- [ ] Phase 4: CI/CD & テスト自動化
