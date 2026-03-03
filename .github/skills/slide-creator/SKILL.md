---
name: slide-creator
description: 'SVG でスライドを設計し、Python スクリプト (svg2pptx.py) で編集可能な PPTX に変換するスキル。デザイントークン・カラーパレット・レイアウト原則を統一し、高品質なプレゼンスライドを生成する。'
---

# SVG スライド作成スキル

## 概要

SVG (960×540) でスライドを設計し、`scripts/svg2pptx.py` で
PowerPoint ネイティブシェイプに変換する。テキスト編集・色変更・移動が可能な状態で出力する。

## トリガーワード

以下のキーワードが含まれる場合にこのスキルを使用する:
- 「PPT作成」「スライド作成」「PowerPoint」「PPTX」
- 「SVGスライド」「SVGで作って」「編集可能なスライド」
- 「プレゼン資料」「スライド」

## 使用しない場合

- Markdown ドキュメント（提案書・報告書・議事録）の作成
- README やコード内コメントの作成
- Word ドキュメントの作成

## 作成ワークフロー

### Step 1: 要件確認

スライド作成の前に必ず確認する:

| 確認項目 | 質問 |
|----------|------|
| 目的 | 何のためのスライド？（提案、報告、教育、共有） |
| 対象読者 | 誰が見る？（経営層、技術者、顧客、社内） |
| ページ数 | 何枚程度？ |
| トーン | フォーマル？カジュアル？ |

### Step 2: アウトライン作成

**必ず内容作成の前にアウトラインを提示し、承認を得る。**

```markdown
## アウトライン案

1. 表紙（タイトルスライド）
2. エグゼクティブサマリー（1枚）
3. 背景・課題（1-2枚）
4. 提案内容（3-5枚）
5. 効果・メリット（1-2枚）
6. スケジュール・ロードマップ（1枚）
7. 次のステップ（1枚）
```

### Step 3: SVG スライド生成

アウトライン承認後、スライドごとに SVG (960×540) を生成する。
本スキルの「SVG スライド設計ルール」「デザイントークン」「カラー使用原則」に従うこと。

---

## PowerPoint スライド作成ルール

### 構造

各スライドは以下の形式で記述する:

```markdown
---
### スライド [番号]: [タイトル]

**キーメッセージ:** [このスライドで伝えたい1文]

**内容:**
- ポイント1
- ポイント2
- ポイント3

**ビジュアル:** [図表・グラフ・画像の説明]

**スピーカーノート:**
[プレゼンで話す内容の補足]
---
```

### デザインディレクション

目指す雰囲気: **Microsoft モダンスライド品質**

> Microsoft の最新のプレゼン資料や Azure マーケティングスライドのような洗練さ。
> 微細なグラデーション、半透明の幾何学装飾、充分な余白、コントラストの効いた配色。
> 「高級コンサルのデリバラブル」であり、「社内勉強会のスライド」ではない。

#### 美的キーワード（生成時に意識する）

- **モダン** — テック企業のプレゼンのような洗練さ。平面的ではなく奥行きがある
- **リッチ** — 安っぽいフラットではなく、微細な装飾とグラデーションで高級感を出す
- **レイヤード** — 半透明の幾何学要素を重ねて深みを作る
- **コントラスト** — ダーク背景ヘッダー × ライト背景コンテンツで視線を導く
- **タイポグラフィ重視** — フォントサイズの差（大タイトル vs 小本文）で階層を作る

#### 装飾の使い方（重要）

微細な装飾で高級感を出す。「何も置かない」のではなく、さりげなく深みを加える。

- **ティール装飾円** — 大きなティール系の円（`#1A3A4A`, `#2A7A8C`）を opacity 0.6〜0.9 で重ね塗り。端がスライド外にはみ出すくらいがちょうどよい。深みと彩りを加える
- **ドットパターン / ネットワーク図形** — 小さな白い円と線でノードを描き、コーナーに配置（opacity 0.2〜0.4）
- **アクセントライン** — 細いラインや区切り線にシアン（`#00D4FF`）を使って視線を引く
- **グロー効果** — 装飾円に radialGradient を使い、シアン（`#00D4FF`）を中心からフェードアウトさせると光の印象が出る

#### グラデーションの使い方（重要）

ベタ塗りの単色背景は平面的でつまらない。**微細なグラデーション**で奥行きと高級感を出す。

SVG では `<defs>` 内に `<linearGradient>` / `<radialGradient>` を定義し、`fill="url(#id)"` で参照する。
svg2pptx.py が自動的に PPTX ネイティブグラデーションに変換する。

##### 推奨グラデーションパターン

| 用途 | タイプ | 開始色 | 終了色 | 方向 |
|------|--------|---------|---------|------|
| タイトルスライド背景 | linear | `#0D1B2A` | `#1B2A4A` | 上→下 |
| ヘッダーバー | linear | `#1B2A4A` | `#1A3A4A` | 左→右 |
| コンテンツ背景 | linear | `#F5F7FA` | `#EEF1F5` | 上→下 |
| 装飾円（ティール） | solid | `#1A3A4A` (opacity 0.7) | — | — |
| 装飾円（シアングロー） | radial | `#00D4FF` (opacity 0.12) | 透明 | 中心→外 |
| カード背景 | linear | `#FAFBFC` | `#EEF1F5` | 上→下 |

##### SVG グラデーションの書き方

```xml
<defs>
  <!-- 細かい縦グラデ: ダークネイビー → やや明るいネイビー -->
  <linearGradient id="bg-dark" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0%" stop-color="#1B2A4A"/>
    <stop offset="100%" stop-color="#243660"/>
  </linearGradient>

  <!-- ヘッダー横グラデ: ダーク → ディープブルー -->
  <linearGradient id="header-grad" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0%" stop-color="#1B2A4A"/>
    <stop offset="100%" stop-color="#2B5797"/>
  </linearGradient>

  <!-- ライト背景グラデ: ほぼ白 → 淡いグレー -->
  <linearGradient id="bg-light" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0%" stop-color="#F5F7FA"/>
    <stop offset="100%" stop-color="#EEF1F5"/>
  </linearGradient>

  <!-- 装飾用放射グラデ: 中心からフェードアウト -->
  <radialGradient id="glow" cx="0.5" cy="0.5" r="0.5">
    <stop offset="0%" stop-color="#4A8BC2" stop-opacity="0.15"/>
    <stop offset="100%" stop-color="#4A8BC2" stop-opacity="0"/>
  </radialGradient>
</defs>

<!-- 使い方 -->
<rect width="960" height="540" fill="url(#bg-dark)"/>
<rect x="0" y="0" width="960" height="70" fill="url(#header-grad)"/>
<circle cx="800" cy="100" r="200" fill="url(#glow)"/>
```

##### グラデーション使用原則

1. **深度グラデーション** — Deep Navy → Navy Dark → Teal Dark の深度差で奥行きを出す。色相が大きく変わるグラデはしない
2. **背景と装飾に使う** — テキストボックスやカード内の小さな要素には不要
3. **派手なレインボーグラデ禁止** — 複数の色相をまたぐグラデーションは NG
4. **放射グラデは装飾専用** — シアングローやライトアクセントとして使う
5. **ストップは最大2つ** — シンプルな2色グラデーションが基本

#### やってはいけないデザイン

- 色のレインボー使い（安っぽくなる）
- 要素の詰め込み（余白なし = 素人感）
- 蛍光色・ビビッド色（#50E6FF, #FF8C00 等）
- すべてのボックスに枠線（うるさくなる）
- **ベタ塗りの単色背景**（平面的でつまらない → グラデーションを使う）
- 装飾のないタイトルスライド（社内勉強会感が出る）
- **派手なレインボーグラデーション**（複数色相をまたぐグラデ = 2010年代感）

### レイアウト原則

- **1スライド1メッセージ** — 詰め込まない
- **箇条書きは最大5点** — 超える場合は分割
- **テキスト量は最小限** — 話す内容はスピーカーノートに
- **図表を優先** — 文章 < 表 < 図 < Mermaid ダイアグラム
- **数字は大きく** — KPI やインパクトは視覚的に強調
- **余白は全体の30%以上** — 左右マージン40px以上、要素間の間隔を十分に取る

### 対象読者別の調整

| 対象 | フォーカス | 避けるべきこと |
|------|-----------|---------------|
| 経営層 | ビジネスインパクト、ROI、リスク | 技術詳細、専門用語 |
| 技術者 | アーキテクチャ、実装、選定理由 | 曖昧な表現、マーケ用語 |
| 顧客 | 課題解決、具体的なメリット | 自社都合の話 |

---

---

## SVG → PPTX ワークフロー（編集可能なスライド生成）

### 概要

SVG (XML ベース) でスライドを設計し、Python スクリプトで PPTX の**ネイティブシェイプ**に変換する。
画像として貼るのではなく、PowerPoint 上で**テキスト編集・色変更・移動**が可能な状態で出力する。

### なぜ SVG 経由なのか

| 比較項目 | Markdown → 手動転記 | SVG → PPTX 変換 |
|----------|---------------------|-----------------|
| デザイン自由度 | 低（テキスト中心） | 高（座標・色・フォント指定可能） |
| 出力の編集性 | — | ネイティブシェイプで完全編集可能 |
| Copilot との相性 | ◎（テキスト生成） | ◎（SVG もテキスト/XML） |
| 見た目の品質 | 手動次第 | プログラム的に統一 |

### ワークフロー

```
Step 1: Copilot が SVG を生成（スライドごとに1つの SVG）
Step 2: Python スクリプト (svg2pptx.py) で PPTX に変換
Step 3: PowerPoint で微調整（テキスト修正、色変更など）
```

### Step 1: SVG スライド設計ルール

Copilot が SVG を生成するときのルール:

#### スライドサイズ

```
幅: 960px（= 25.4cm、標準 16:9）
高さ: 540px
```

#### 使用する SVG 要素と PPTX マッピング

| SVG 要素 | PPTX でのマッピング | 用途 |
|----------|---------------------|------|
| `<rect>` | AutoShape (Rectangle) | 背景、ボックス、カード |
| `<rect rx="...">` | AutoShape (Rounded Rectangle) | 角丸ボックス |
| `<text>` | TextBox | タイトル、本文、ラベル |
| `<circle>` / `<ellipse>` | AutoShape (Oval) | アイコン背景、装飾 |
| `<line>` | Connector | 区切り線、接続線 |
| `<polygon>` | Freeform Shape | 矢印、カスタム図形 |
| `<g>` | Group Shape | 要素のグループ化 |
| `<defs>` | （定義用） | グラデーション等の定義置き場 |
| `<linearGradient>` | GradientFill (linear) | 線形グラデーション |
| `<radialGradient>` | GradientFill (path) | 放射グラデーション |

#### SVG テンプレート構造

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 540">
  <defs>
    <!-- コンテンツ背景グラデ -->
    <linearGradient id="bg-light" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#F5F7FA"/>
      <stop offset="100%" stop-color="#EEF1F5"/>
    </linearGradient>
    <!-- ヘッダー横グラデ: ネイビー → ティール -->
    <linearGradient id="header-grad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#1B2A4A"/>
      <stop offset="100%" stop-color="#1A3A4A"/>
    </linearGradient>
  </defs>

  <!-- 背景（微細グラデーション） -->
  <rect width="960" height="540" fill="url(#bg-light)"/>

  <!-- タイトルバー（横グラデーション） -->
  <rect x="0" y="0" width="960" height="80" fill="url(#header-grad)"/>
  <text x="40" y="52" font-size="28" font-weight="bold"
        fill="#FFFFFF" font-family="Segoe UI">スライドタイトル</text>

  <!-- コンテンツエリア -->
  <text x="40" y="140" font-size="18" fill="#1E2328"
        font-family="Segoe UI">• ポイント1</text>
  <text x="40" y="175" font-size="18" fill="#1E2328"
        font-family="Segoe UI">• ポイント2</text>

  <!-- カード型レイアウト例 -->
  <rect x="40" y="220" width="260" height="160" rx="8"
        fill="#EEF1F5" stroke="#C8CED6"/>
  <text x="60" y="260" font-size="16" font-weight="bold"
        fill="#1E2328" font-family="Segoe UI">カード1</text>
  <text x="60" y="290" font-size="14"
        fill="#4A5568" font-family="Segoe UI">説明テキスト</text>
</svg>
```

#### デザイントークン（カラーパレット）

##### メインパレット（深海ネイビー × シアンアクセント）

```
Deep Navy:    #0D1B2A (最深ネイビー — タイトルスライド全面背景)
Navy Dark:    #1B2A4A (ダークネイビー — ヘッダー・セクション背景)
Teal Dark:    #1A3A4A (ダークティール — 装飾円・オーバーレイ)
Teal:         #2A7A8C (ティール — 装飾グラデーション・中間色)
Cyan:         #00D4FF (ブライトシアン — アクセント見出し・強調線)
Cyan Pale:    #E0F7FA (ペイルシアン — ライト背景のアクセント帯)
```

##### ニュートラル（テキスト・背景・ボーダー）

```
Background:   #FAFBFC (メイン背景 — ほぼ白)
Surface:      #EEF1F5 (カード・セクション背景)
Border:       #C8CED6 (ボーダー・区切り線)
Text Dark:    #1E2328 (タイトル・見出し)
Text Body:    #4A5568 (本文テキスト)
Text Muted:   #8B939E (補足・注釈)
White:        #FFFFFF (テキストon暗背景)
Text Light:   #B0C4D8 (暗背景上のサブテキスト・説明文)
```

##### アクセント（控えめに使用 — 1スライドに最大1色）

```
Warm:         #8B6914 (少量の注意喚起ポイント用)
```

##### ステータス色（凡例・アイコン専用 — 本文では使わない）

```
Success:      #2D6A4F (落ち着いた緑)
Warning:      #B8860B (渋いゴールド)
Error:        #9B2C2C (深い赤)
```

#### カラー使用原則

1. **1スライド最大4色** — Navy系 + シアン + ニュートラル + (任意で) アクセント1色
2. **深度で差をつける** — Deep Navy → Navy Dark → Teal Dark の深度グラデーションで奥行きを出す
3. **シアンはアクセント専用** — 見出し・強調線・サブタイトルなど目を引く要素に使う。面積15%以下
4. **暗背景にティール装飾** — 大きなティール円を重ねて深みと彩りを加える
5. **レインボー禁止** — 凡例やカテゴリ分けも同系色の濃淡で表現する
6. **ダーク背景ヘッダー + ライト背景本文** — コントラストで高級感を出す

### Step 2: 変換スクリプト実行

```bash
# 変換実行（フォルダ名から自動命名）
python scripts/svg2pptx.py output/slides/2026-03-03_143052_テーマ名/
# → 2026-03-03_テーマ名.pptx が同フォルダに生成される

# 出力ファイル名を明示する場合
python scripts/svg2pptx.py slides/ -o custom_name.pptx
```

変換スクリプトの実体は `scripts/svg2pptx.py`（リポジトリルート）。

### Step 3: PowerPoint での微調整

変換後の PPTX は以下が編集可能:
- テキストの直接編集
- シェイプの色・サイズ変更
- 要素の移動・追加・削除
- アニメーションの追加
- スピーカーノートの編集

### SVG スライドパターン集

#### パターン1: タイトルスライド

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 540">
  <defs>
    <!-- タイトル背景: 最深ネイビー → ダークネイビー -->
    <linearGradient id="bg-dark" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0D1B2A"/>
      <stop offset="100%" stop-color="#1B2A4A"/>
    </linearGradient>
    <!-- シアングロー: 中心から半透明フェードアウト -->
    <radialGradient id="glow-cyan" cx="0.5" cy="0.5" r="0.5">
      <stop offset="0%" stop-color="#00D4FF" stop-opacity="0.12"/>
      <stop offset="100%" stop-color="#00D4FF" stop-opacity="0"/>
    </radialGradient>
  </defs>

  <!-- 背景: 深度グラデーションで奥行き -->
  <rect width="960" height="540" fill="url(#bg-dark)"/>

  <!-- ティール装飾円: 大きく重ねて深みを出す -->
  <circle cx="650" cy="480" r="300" fill="#1A3A4A" opacity="0.7"/>
  <circle cx="850" cy="400" r="220" fill="#2A7A8C" opacity="0.5"/>

  <!-- シアングロー（右上） -->
  <circle cx="800" cy="100" r="200" fill="url(#glow-cyan)"/>

  <!-- ネットワーク図形（コーナー装飾） -->
  <circle cx="800" cy="80" r="3" fill="#FFFFFF" opacity="0.4"/>
  <circle cx="840" cy="60" r="3" fill="#FFFFFF" opacity="0.4"/>
  <circle cx="870" cy="100" r="3" fill="#FFFFFF" opacity="0.4"/>
  <circle cx="830" cy="120" r="3" fill="#FFFFFF" opacity="0.4"/>
  <circle cx="860" cy="140" r="3" fill="#FFFFFF" opacity="0.3"/>
  <line x1="800" y1="80" x2="840" y2="60" stroke="#FFFFFF" stroke-width="1" opacity="0.2"/>
  <line x1="840" y1="60" x2="870" y2="100" stroke="#FFFFFF" stroke-width="1" opacity="0.2"/>
  <line x1="870" y1="100" x2="830" y2="120" stroke="#FFFFFF" stroke-width="1" opacity="0.2"/>
  <line x1="830" y1="120" x2="800" y2="80" stroke="#FFFFFF" stroke-width="1" opacity="0.2"/>

  <!-- タイトル -->
  <text x="80" y="220" font-size="36" font-weight="bold"
        fill="#FFFFFF" font-family="Segoe UI">プレゼンテーションタイトル</text>

  <!-- サブタイトル（ブライトシアン） -->
  <text x="80" y="270" font-size="22"
        fill="#00D4FF" font-family="Segoe UI">サブタイトル</text>

  <!-- アクセントライン（シアン） -->
  <line x1="80" y1="290" x2="280" y2="290"
        stroke="#00D4FF" stroke-width="3"/>

  <!-- 補足情報 -->
  <text x="80" y="330" font-size="14"
        fill="#B0C4D8" font-family="Segoe UI">補足説明テキストをここに</text>
  <text x="80" y="355" font-size="14"
        fill="#B0C4D8" font-family="Segoe UI">2行目の補足テキスト</text>

  <!-- 日付 -->
  <text x="80" y="490" font-size="14"
        fill="#8B939E" font-family="Segoe UI">2026年3月</text>

  <!-- フッター -->
  <text x="880" y="520" font-size="12"
        fill="#8B939E" font-family="Segoe UI"
        text-anchor="end">Microsoft Azure</text>
</svg>
```

#### パターン2: 3カラムカード

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 540">
  <defs>
    <linearGradient id="bg-light" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#F5F7FA"/>
      <stop offset="100%" stop-color="#EEF1F5"/>
    </linearGradient>
    <linearGradient id="header-grad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#1B2A4A"/>
      <stop offset="100%" stop-color="#1A3A4A"/>
    </linearGradient>
  </defs>

  <rect width="960" height="540" fill="url(#bg-light)"/>
  <rect x="0" y="0" width="960" height="70" fill="url(#header-grad)"/>
  <text x="40" y="46" font-size="24" font-weight="bold"
        fill="#FFFFFF" font-family="Segoe UI">3つのポイント</text>

  <!-- カード1（ダークネイビー） -->
  <rect x="40" y="100" width="270" height="380" rx="8"
        fill="#EEF1F5" stroke="#C8CED6"/>
  <circle cx="175" cy="170" r="35" fill="#1B2A4A"/>
  <text x="175" y="178" font-size="24" fill="#FFFFFF"
        font-family="Segoe UI" text-anchor="middle">1</text>
  <text x="175" y="240" font-size="18" font-weight="bold"
        fill="#1E2328" font-family="Segoe UI"
        text-anchor="middle">ポイント1</text>
  <text x="60" y="280" font-size="14"
        fill="#4A5568" font-family="Segoe UI">説明テキストを</text>
  <text x="60" y="300" font-size="14"
        fill="#4A5568" font-family="Segoe UI">ここに記載する</text>

  <!-- カード2（ダークティール） -->
  <rect x="345" y="100" width="270" height="380" rx="8"
        fill="#EEF1F5" stroke="#C8CED6"/>
  <circle cx="480" cy="170" r="35" fill="#1A3A4A"/>
  <text x="480" y="178" font-size="24" fill="#FFFFFF"
        font-family="Segoe UI" text-anchor="middle">2</text>
  <text x="480" y="240" font-size="18" font-weight="bold"
        fill="#1E2328" font-family="Segoe UI"
        text-anchor="middle">ポイント2</text>

  <!-- カード3（シアンアクセント） -->
  <rect x="650" y="100" width="270" height="380" rx="8"
        fill="#EEF1F5" stroke="#C8CED6"/>
  <circle cx="785" cy="170" r="35" fill="#2A7A8C"/>
  <text x="785" y="178" font-size="24" fill="#FFFFFF"
        font-family="Segoe UI" text-anchor="middle">3</text>
  <text x="785" y="240" font-size="18" font-weight="bold"
        fill="#1E2328" font-family="Segoe UI"
        text-anchor="middle">ポイント3</text>
</svg>
```

#### パターン3: 比較表

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 540">
  <defs>
    <linearGradient id="bg-light" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#F5F7FA"/>
      <stop offset="100%" stop-color="#EEF1F5"/>
    </linearGradient>
    <linearGradient id="header-grad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#1B2A4A"/>
      <stop offset="100%" stop-color="#1A3A4A"/>
    </linearGradient>
    <linearGradient id="col-left" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#1B2A4A"/>
      <stop offset="100%" stop-color="#1A3A4A"/>
    </linearGradient>
    <linearGradient id="col-right" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#1A3A4A"/>
      <stop offset="100%" stop-color="#2A7A8C"/>
    </linearGradient>
  </defs>

  <rect width="960" height="540" fill="url(#bg-light)"/>
  <rect x="0" y="0" width="960" height="70" fill="url(#header-grad)"/>
  <text x="40" y="46" font-size="24" font-weight="bold"
        fill="#FFFFFF" font-family="Segoe UI">比較: A vs B</text>

  <!-- 左カラム（ネイビー → ティールグラデ） -->
  <rect x="40" y="100" width="420" height="50" rx="4"
        fill="url(#col-left)"/>
  <text x="250" y="132" font-size="18" font-weight="bold"
        fill="#FFFFFF" font-family="Segoe UI"
        text-anchor="middle">プランA</text>
  <rect x="40" y="155" width="420" height="40"
        fill="#EEF1F5" stroke="#C8CED6"/>
  <text x="60" y="180" font-size="14"
        fill="#1E2328" font-family="Segoe UI">特徴1の説明</text>

  <!-- 右カラム（ティールグラデ — 同系色で対比） -->
  <rect x="500" y="100" width="420" height="50" rx="4"
        fill="url(#col-right)"/>
  <text x="710" y="132" font-size="18" font-weight="bold"
        fill="#FFFFFF" font-family="Segoe UI"
        text-anchor="middle">プランB</text>
  <rect x="500" y="155" width="420" height="40"
        fill="#EEF1F5" stroke="#C8CED6"/>
  <text x="520" y="180" font-size="14"
        fill="#1E2328" font-family="Segoe UI">特徴1の説明</text>
</svg>
```

---

## 出力ルール

### 保存先

| 成果物の種類 | 保存先 |
|-------------|--------|
| SVG スライド | `output/slides/YYYY-MM-DD_HHmmss_スライド名/slide01.svg` 〜 |
| 変換後 PPTX | `output/slides/YYYY-MM-DD_HHmmss_スライド名/YYYY-MM-DD_スライド名.pptx`（自動命名） |

### 重複回避

フォルダ名に時分秒（`HHmmss`）を含めることで自然に一意になる。
同日・同テーマでも実行時刻が異なれば別フォルダになるため、サフィックス管理は不要。

```
output/slides/2026-03-03_143052_ACA-ネットワーク/   ← 1回目（14:30:52）
output/slides/2026-03-03_153210_ACA-ネットワーク/   ← 2回目（15:32:10）
```

- 既存ファイルは絶対に上書き・削除しない

### 品質基準

- 日本語で作成する
- そのまま使える品質を目指す
- 具体的な数字・事実を優先する（「多くの」ではなく「80%の」）
- 各セクションの分量バランスを意識する
- ドキュメントの最後に情報源一覧を入れる

### SVG 出力時の追加ルール

- スライドサイズ `960x540` を厳守する
- デザイントークンのカラーパレットに従う（メインパレット + ニュートラルが基本）
- **カラー使用原則を必ず守る** — 1スライド最大4色、深度で差をつける、シアンはアクセント専用
- **グラデーション必須** — 背景やヘッダーはベタ塗りでなく `<defs>` にグラデーションを定義して `fill="url(#id)"` で参照する
- **`<defs>` を SVG の先頭に置く** — グラデーション定義はすべて `<defs>...</defs>` 内にまとめる
- **ティール装飾円** — ダーク背景のタイトルスライドには大きなティール円（`#1A3A4A`, `#2A7A8C`）を重ねて深みを出す
- アクセント色（Warm）は明確な意図がある場合のみ使用する
- ファイル名は `slide01.svg`, `slide02.svg`, ... の連番
- **ハイパーリンク** — 情報源の URL を `<a>` タグで埋め込む（PPTX でクリック可能になる）

### 🚫 禁止カラー（絶対に使わない）

以下の Azure ブランドカラーは**絶対に使用禁止**。トレーニングデータの影響で出力されがちだが、カスタムパレットのみを使うこと。

| 色名 | Hex | 代わりに使う色 |
|------|-----|---------------|
| Azure Blue | `#0078D4` | `#1B2A4A`（Deep Navy）または `#00D4FF`（Cyan） |
| Azure Light Blue | `#50E6FF` | `#00D4FF`（Bright Cyan） |
| Azure Dark Blue | `#005A9E` | `#0D1B2A`（Deep Navy Dark） |
| Azure Pale Blue | `#B4D6F5` | `#E0F7FA`（Light Cyan） |
| Azure Green | `#107C10` | 使用しない |
| Azure Yellow | `#FFB900` | `#F4A261`（Warm Accent Orange、必要時のみ） |
| Azure Red | `#E81123` | `#E76F51`（Warm Accent Coral、必要時のみ） |
| Azure Purple | `#8764B8` | 使用しない |

**判定基準**: `#0078D4` や `#50E6FF` が SVG に含まれていたら**間違い**。必ず上記カスタムパレットの色に置き換える。

### 🚫 SVG 構造の制約

PPTX 変換の互換性と品質を保つため、以下のルールを厳守する。

**座標の直接指定（必須）:**
- 各要素（`<rect>`, `<text>`, `<circle>` 等）の座標は `x`, `y`, `cx`, `cy` 等の属性で**直接指定**する
- `<g transform="translate(x, y)">` による間接オフセットは**避ける**（svg2pptx.py は対応しているが、デバッグしづらくなるため非推奨）

**スタイル属性の直書き（推奨）:**
- `style="fill: #0D1B2A; stroke: none"` ではなく、`fill="#0D1B2A" stroke="none"` のように属性として直接記述する
- グラデーションの `<stop>` も `stop-color="#0D1B2A"` を属性で書く（`style="stop-color:..."` は避ける）

**OK な例:**
```xml
<rect x="100" y="50" width="200" height="80" fill="url(#grad1)" rx="8"/>
<text x="120" y="90" font-size="16" fill="#E0F7FA">テキスト</text>
```

**NG な例（避ける）:**
```xml
<!-- ❌ translate でオフセット -->
<g transform="translate(100, 50)">
  <rect x="0" y="0" width="200" height="80" fill="#0078D4"/>
</g>
<!-- ❌ style 属性に CSS を詰め込む -->
<rect x="100" y="50" style="fill: #0078D4; width: 200px"/>
<!-- ❌ Azure ブランドカラー -->
<rect x="0" y="0" width="960" height="80" fill="#0078D4"/>
```

### ハイパーリンクの記法

各スライドに情報源（MS Learn 等）へのリンクを入れる場合、SVG の `<a>` タグを使う:

```xml
<!-- パターン A: テキスト全体がリンク -->
<a href="https://learn.microsoft.com/ja-jp/azure/...">
  <text x="30" y="520" font-size="10" fill="#00D4FF">📖 詳細: MS Learn →</text>
</a>

<!-- パターン B: テキストの一部がリンク（<text> 内に <a> を入れる） -->
<text x="30" y="520" font-size="10" fill="#B0C4D8">
  出典:
  <a href="https://learn.microsoft.com/ja-jp/azure/...">
    <tspan fill="#00D4FF">MS Learn — Azure Container Apps</tspan>
  </a>
</text>
```

**ルール:**
- リンクテキストの fill は `#00D4FF`（Cyan）で統一する
- フッター付近（`y="510"〜520"`）に配置する
- 調査スライドには必ず情報源リンクを入れる
