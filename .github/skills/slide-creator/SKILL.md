---
name: slide-creator
description: 'SVG でスライドを設計し、Python スクリプト (svg2pptx.py) で編集可能な PPTX に変換するスキル。デザイントークン・カラーパレット・レイアウト原則を統一し、高品質なプレゼンスライドを生成する。'
---

# SVG スライド作成スキル

## 概要

SVG (960×540) でスライドを設計し、`src/svg2pptx.py` で
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

目指す雰囲気: **Microsoft Ignite 2025 キーノートスライド品質**

> Microsoft Ignite 2025 のキーノートセッションで使われるような洗練さ。
> パープル × ブルー × マゼンタの多色グラデーション、ガラス質の光沢装飾、
> 充分な余白、ダーク背景（パープルブラック）とライト背景（ライラック）を使い分ける。
> 「最先端 AI プラットフォーム企業のプレゼン」であり、「社内勉強会のスライド」ではない。

#### 美的キーワード（生成時に意識する）

- **Cosmic** — パープルブラックの深い宇宙的な背景。暗めの中に光のアクセントが映える
- **Depth** — すべての面にグラデーションを入れ、フラットなベタ塗りを排除。カードも背景もアイコンも
- **Glassmorphism** — 半透明のオーバーレイ、ぼかし的な重なりで奥行きと高級感を作る
- **Monochrome Accent** — アクセントはパープル系の同系色グラデーション（`#2D1B69` → `#7B3FA0`）が基本。マゼンタやシアンは単色ポイントとして使い、直接繋がないこと
- **タイポグラフィ重視** — フォントサイズの差（大タイトル vs 小本文）で明確な階層を作る

#### 装飾の使い方（重要）

微細な装飾で高級感を出す。タイトルスライドだけでなく、**コンテンツスライドにも必ず装飾を入れる**。

- **パープルグロー** — radialGradient で `#7B3FA0` や `#4A2D99` を中心からフェードアウト。コーナーに配置して柔らかい光の印象を出す。**すべてのスライドに最低1つ**
- **パープル斜線** — 薄い斜めのライン（`#7B3FA0`, opacity 0.2〜0.4）をスライド右上隅に走らせてモダンさを出す
- **アクセントピル** — 丸角のピル型ラベルには `#2D1B69` → `#7B3FA0` のパープル同系グラデーションを使う
- **アクセントライン** — セクション区切り線に `#4A2D99` → `#7B3FA0` のパープル横グラデーションを使う
- **ライラックの面** — ライト背景スライドの片側にパープル系の淡いグラデーション面を配置して色味を加える

#### グラデーションの使い方（最重要）

**あらゆる面にグラデーションを入れる。フラットなベタ塗りは禁止。**
カードも、アイコン円も、バッジも、背景もすべてグラデーションで深みを出す。

SVG では `<defs>` 内に `<linearGradient>` / `<radialGradient>` を定義し、`fill="url(#id)"` で参照する。
svg2pptx.py が自動的に PPTX ネイティブグラデーションに変換する。

##### 🚫 絶対禁止: マゼンタ→シアン直行グラデーション

**`#E047A0` → `#00D4FF` の2ストップ直行グラデーションは絶対に使わない。**
ピンク→水色のジャンプはアイスクリームショップ感を生み、企業プレゼンにそぐわない。

代わりに:
- **パープル × ブルー × マゼンタの隣接色グラデーション**をメインに使う
  - パープル→ディープブルー: `#2D1B69` → `#1E3A8A`
  - パープル→インディゴ: `#4A2D99` → `#3730A3`
  - パープル→ディープマゼンタ: `#7B3FA0` → `#9B2D8E`
- マゼンタ `#E047A0` は**単色のポイントカラー**として小面積に使う（テキスト、小さなドット、線）
- シアン `#00D4FF` も**単色のポイントカラー**として使う（リンクテキスト、細い線）
- もし両方を1つのグラデーションに入れたい場合は、**必ず中間にパープルを挟む3ストップ**で:
  `#E047A0` → `#7B3FA0` → `#00D4FF`（ただし使用は稀 — 特別な強調時のみ）

##### 推奨グラデーションパターン

| 用途 | タイプ | カラーストップ | 方向 |
|------|--------|----------------|------|
| タイトルスライド背景 | linear | `#0D0D1A` → `#0D1A2E` → `#1A0A2E` → `#2D1B69` | 上→下 |
| ヘッダーバー（パターンA） | linear | `#2D1B69` → `#1E3A8A` | 左→右 |
| ヘッダーバー（パターンB） | linear | `#2D1B69` → `#4A2D99` → `#3730A3` | 左→右 |
| コンテンツ背景（ライト） | linear | `#F0F4FA` → `#F5F0FA` → `#EDE8F5` | 上→下 |
| カード背景（パターンA） | linear | `#FFFFFF` → `#F0ECF5` | 上→下 |
| カード背景（パターンB） | linear | `#FFFFFF` → `#EEF2FF` | 上→下 |
| アクセントピル（パープル系） | linear | `#2D1B69` → `#7B3FA0` | 左→右 |
| アクセントピル（ブルー系） | linear | `#1E3A8A` → `#3730A3` | 左→右 |
| アクセントピル（マゼンタ系） | linear | `#7B3FA0` → `#9B2D8E` | 左→右 |
| アイコン円（パープル→ブルー） | linear | `#2D1B69` → `#1E3A8A` | 左上→右下 |
| アイコン円（パープル→マゼンタ） | linear | `#4A2D99` → `#9B2D8E` | 左上→右下 |
| アイコン円（インディゴ） | linear | `#312E81` → `#3730A3` | 左上→右下 |
| 装飾グロー（パープル） | radial | `#7B3FA0` (opacity 0.12) → 透明 | 中心→外 |
| 装飾グロー（ブルー） | radial | `#1E3A8A` (opacity 0.10) → 透明 | 中心→外 |
| 装飾グロー（マゼンタ） | radial | `#9B2D8E` (opacity 0.08) → 透明 | 中心→外 |
| フロー矢印・強調ブロック | linear | `#3730A3` → `#7B3FA0` | 左→右 |
| 特別強調（稀） | linear | `#E047A0` → `#7B3FA0` → `#00D4FF` | 左→右 |

##### SVG グラデーションの書き方

```xml
<defs>
  <!-- ダーク背景: ネイビー～パープルの深い階調 -->
  <linearGradient id="bg-dark" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0%" stop-color="#0D0D1A"/>
    <stop offset="35%" stop-color="#0D1A2E"/>
    <stop offset="65%" stop-color="#1A0A2E"/>
    <stop offset="100%" stop-color="#2D1B69"/>
  </linearGradient>

  <!-- ヘッダー横グラデ A: パープル → ディープブルー -->
  <linearGradient id="header-grad-a" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0%" stop-color="#2D1B69"/>
    <stop offset="100%" stop-color="#1E3A8A"/>
  </linearGradient>

  <!-- ヘッダー横グラデ B: パープル → インディゴ -->
  <linearGradient id="header-grad-b" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0%" stop-color="#2D1B69"/>
    <stop offset="50%" stop-color="#4A2D99"/>
    <stop offset="100%" stop-color="#3730A3"/>
  </linearGradient>

  <!-- ライト背景グラデ: ブルー～ライラックのニュアンス -->
  <linearGradient id="bg-light" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0%" stop-color="#F0F4FA"/>
    <stop offset="50%" stop-color="#F5F0FA"/>
    <stop offset="100%" stop-color="#EDE8F5"/>
  </linearGradient>

  <!-- カード背景 A: 白 → ライラック -->
  <linearGradient id="card-grad-a" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0%" stop-color="#FFFFFF"/>
    <stop offset="100%" stop-color="#F0ECF5"/>
  </linearGradient>

  <!-- カード背景 B: 白 → ペールブルー -->
  <linearGradient id="card-grad-b" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0%" stop-color="#FFFFFF"/>
    <stop offset="100%" stop-color="#EEF2FF"/>
  </linearGradient>

  <!-- アクセントピル: パープル系 -->
  <linearGradient id="pill-purple" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0%" stop-color="#2D1B69"/>
    <stop offset="100%" stop-color="#7B3FA0"/>
  </linearGradient>

  <!-- アクセントピル: ブルー系 -->
  <linearGradient id="pill-blue" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0%" stop-color="#1E3A8A"/>
    <stop offset="100%" stop-color="#3730A3"/>
  </linearGradient>

  <!-- アクセントピル: マゼンタ系 -->
  <linearGradient id="pill-magenta" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0%" stop-color="#7B3FA0"/>
    <stop offset="100%" stop-color="#9B2D8E"/>
  </linearGradient>

  <!-- アイコン円 A: パープル → ディープブルー -->
  <linearGradient id="icon-grad-a" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0%" stop-color="#2D1B69"/>
    <stop offset="100%" stop-color="#1E3A8A"/>
  </linearGradient>

  <!-- アイコン円 B: パープル → マゼンタ -->
  <linearGradient id="icon-grad-b" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0%" stop-color="#4A2D99"/>
    <stop offset="100%" stop-color="#9B2D8E"/>
  </linearGradient>

  <!-- アイコン円 C: インディゴ -->
  <linearGradient id="icon-grad-c" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0%" stop-color="#312E81"/>
    <stop offset="100%" stop-color="#3730A3"/>
  </linearGradient>

  <!-- パープルグロー: 装飾用 -->
  <radialGradient id="glow-purple" cx="0.85" cy="0.8" r="0.4">
    <stop offset="0%" stop-color="#7B3FA0" stop-opacity="0.12"/>
    <stop offset="100%" stop-color="#7B3FA0" stop-opacity="0"/>
  </radialGradient>

  <!-- ブルーグロー: 装飾用（パープルグローと色を変えてバリエーション） -->
  <radialGradient id="glow-blue" cx="0.15" cy="0.2" r="0.35">
    <stop offset="0%" stop-color="#1E3A8A" stop-opacity="0.10"/>
    <stop offset="100%" stop-color="#1E3A8A" stop-opacity="0"/>
  </radialGradient>

  <!-- マゼンタグロー: 装飾用（アクセント） -->
  <radialGradient id="glow-magenta" cx="0.5" cy="0.9" r="0.3">
    <stop offset="0%" stop-color="#9B2D8E" stop-opacity="0.08"/>
    <stop offset="100%" stop-color="#9B2D8E" stop-opacity="0"/>
  </radialGradient>
</defs>

<!-- 使い方 -->
<rect width="960" height="540" fill="url(#bg-light)"/>
<circle cx="850" cy="430" r="250" fill="url(#glow-purple)"/>  <!-- 装飾グロー -->
<rect x="0" y="0" width="960" height="70" fill="url(#header-grad)"/>
<rect x="40" y="100" width="270" height="160" rx="12" fill="url(#card-grad)" stroke="#D1D5DB"/>
<circle cx="175" cy="170" r="30" fill="url(#icon-grad)"/>
<rect x="50" y="268" width="120" height="24" rx="12" fill="url(#pill-grad)"/>
```

##### グラデーション使用原則

1. **すべての面にグラデーション** — 背景、カード、アイコン円、ピル、ヘッダー。`fill="#xxxxxx"` のベタ塗りは原則禁止（テキストと線は例外）
2. **隣接色で多色グラデーション** — パープル・ディープブルー・インディゴ・ディープマゼンタの色相環で隣り合う色同士を組み合わせる。1スライド内で2〜3種類の異なる色調のグラデーションを混在させて彩りを出す
3. **スライドごとに色を変える** — 同じグラデーションパターンをすべてのスライドで使い回さない。ヘッダー、アイコン、ピルの色をスライドごとに変えてバリエーションを出す
4. **マゼンタ・シアンは単色ポイント** — グラデーション端点としてではなく、テキスト色・細い線・小さなドットとして使う
5. **マゼンタ→シアン直行は絶対禁止** — 中間にパープルを挟まないピンク→水色は NG。3ストップでも使用は稀に
6. **装飾グローはすべてのスライドに** — 色を変えて配置（パープルグロー、ブルーグロー、マゼンタグローを組み合わせる）
7. **カード背景は2パターン** — 白→ライラック `#F0ECF5` と白→ペールブルー `#EEF2FF` を使い分ける
8. **ストップは2〜4つ** — ダーク背景は4ストップ可、その他は2〜3ストップ

#### やってはいけないデザイン

- 要素の詰め込み（余白なし = 素人感）
- **マゼンタ→シアン直行グラデーション**（`#E047A0` → `#00D4FF` はアイスクリーム感。絶対禁止）
- **ベタ塗りのカード・アイコン**（`fill="#FAFBFC"` のフラット面は素人感。グラデーションを使う）
- 蛍光色のべた面積使用（マゼンタやシアンは小面積のポイントカラーに限定）
- すべてのボックスに枠線（うるさくなる）
- **装飾のないコンテンツスライド**（パープルグロー装飾をすべてのスライドに入れる）
- 装飾のないタイトルスライド（社内勉強会感が出る）
- **ネイビー系の配色**（旧テーマ。`#0D1B2A`, `#1B2A4A`, `#1A3A4A` は使わない）
- **グレー一色の背景**（ライラック系グラデーションを使う）

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
    <!-- コンテンツ背景グラデ: ライラック系 -->
    <linearGradient id="bg-light" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#F5F0FA"/>
      <stop offset="100%" stop-color="#EDE8F5"/>
    </linearGradient>
    <!-- ヘッダー横グラデ: パープル → ブルーバイオレット -->
    <linearGradient id="header-grad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#2D1B69"/>
      <stop offset="100%" stop-color="#4A2D99"/>
    </linearGradient>
    <!-- カード背景: 白 → ライラック -->
    <linearGradient id="card-grad" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="100%" stop-color="#F0ECF5"/>
    </linearGradient>
    <!-- 装飾グロー: すべてのスライドに必須 -->
    <radialGradient id="glow-purple" cx="0.85" cy="0.8" r="0.35">
      <stop offset="0%" stop-color="#7B3FA0" stop-opacity="0.10"/>
      <stop offset="100%" stop-color="#7B3FA0" stop-opacity="0"/>
    </radialGradient>
  </defs>

  <!-- 背景（ライラック系グラデーション） -->
  <rect width="960" height="540" fill="url(#bg-light)"/>

  <!-- 装飾グロー（右下隅 — すべてのスライドに最低1つ必須） -->
  <circle cx="820" cy="440" r="200" fill="url(#glow-purple)"/>

  <!-- タイトルバー（パープル横グラデーション） -->
  <rect x="0" y="0" width="960" height="80" fill="url(#header-grad)"/>
  <text x="40" y="52" font-size="28" font-weight="bold"
        fill="#FFFFFF" font-family="Segoe UI">スライドタイトル</text>

  <!-- コンテンツエリア -->
  <text x="40" y="140" font-size="18" fill="#1A1A2E"
        font-family="Segoe UI">• ポイント1</text>
  <text x="40" y="175" font-size="18" fill="#1A1A2E"
        font-family="Segoe UI">• ポイント2</text>

  <!-- カード型レイアウト例（グラデーション背景 + 丸角 rx=12） -->
  <rect x="40" y="220" width="260" height="160" rx="12"
        fill="url(#card-grad)" stroke="#D1D5DB"/>
  <text x="60" y="260" font-size="16" font-weight="bold"
        fill="#1A1A2E" font-family="Segoe UI">カード1</text>
  <text x="60" y="290" font-size="14"
        fill="#4A4A6A" font-family="Segoe UI">説明テキスト</text>
</svg>
```

#### デザイントークン（カラーパレット）

##### メインパレット（Ignite Purple × モノクロームアクセント）

```
Cosmic Black:    #0D0D1A (最深パープルブラック — ダーク背景の基調色)
Deep Violet:     #1A0A2E (ディープバイオレット — タイトルスライド全面背景)
Purple Dark:     #2D1B69 (パープルダーク — ヘッダー・セクション背景)
Blue Violet:     #4A2D99 (ブルーバイオレット — 装飾グラデーション中間色)
Purple Glow:     #7B3FA0 (パープルグロー — 装飾用 radialGradient)
Magenta:         #E047A0 (マゼンタ — アクセントグラデーション端点)
Cyan:            #00D4FF (ブライトシアン — アクセントグラデーション端点)
```

##### ニュートラル（テキスト・背景・ボーダー）

```
Background:   #FAFBFC (メイン背景 — ほぼ白)
Lilac Light:  #F5F0FA (ライトライラック — ライト背景のパープルティント)
Surface:      #F0ECF5 (カード・セクション背景)
Surface Alt:  #EDE8F5 (グラデーション終端・サブ面)
Border:       #D1D5DB (ボーダー・区切り線)
Text Dark:    #1A1A2E (タイトル・見出し)
Text Body:    #4A4A6A (本文テキスト)
Text Muted:   #8B8BA0 (補足・注釈)
White:        #FFFFFF (テキストon暗背景)
Text Light:   #C8C0D8 (暗背景上のサブテキスト・説明文)
```

##### アクセント（グラデーションピルやバッジに使用）

```
Teal Green:   #00B894 (ティールグリーン — サブアクセント・バッジ背景)
```

##### ステータス色（凡例・アイコン専用 — 本文では使わない）

```
Success:      #2D6A4F (落ち着いた緑)
Warning:      #B8860B (渋いゴールド)
Error:        #9B2C2C (深い赤)
```

#### カラー使用原則

1. **1スライド最大5色** — パープル系 + ポイントカラー（マゼンタ or シアン）+ ニュートラル + (任意で) アクセント1色
2. **パープル同系グラデーションが基本** — `#2D1B69` → `#4A2D99` → `#7B3FA0` の同系色グラデーションであらゆる面に深みを出す
3. **マゼンタ・シアンは単色ポイント** — テキスト、細い線、小さなドットに使う。**グラデーションの端点として直接繋がない**（マゼンタ → シアン直行は絶対禁止）
4. **すべての面にグラデーション** — カード・アイコン円・ピル・背景はすべてグラデーション。`fill="#xxxxxx"` のベタ塗りは禁止（テキスト・線は例外）
5. **装飾グローはすべてのスライドに** — パープルグロー（radialGradient）をすべてのスライドに最低1つ配置
6. **ライト背景はライラック系** — `#F5F0FA` → `#EDE8F5` のパープルティント背景で統一感を出す
7. **文字は背景と明度差を確保** — コントラスト比 4.5:1 以上。薄色文字はダーク背景のみ

### Step 2: 変換スクリプト実行

```bash
# 変換実行（フォルダ名から自動命名）
python src/svg2pptx.py output/slides/2026-03-03_143052_テーマ名/
# → 2026-03-03_テーマ名.pptx が同フォルダに生成される

# 出力ファイル名を明示する場合
python src/svg2pptx.py slides/ -o custom_name.pptx
```

変換スクリプトの実体は `src/svg2pptx.py`（リポジトリルート）。

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
    <!-- タイトル背景: 3ストップで深みのあるパープル階調 -->
    <linearGradient id="bg-dark" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0D0D1A"/>
      <stop offset="50%" stop-color="#1A0A2E"/>
      <stop offset="100%" stop-color="#2D1B69"/>
    </linearGradient>
    <!-- パープルグロー: 右上に配置 -->
    <radialGradient id="glow-purple" cx="0.8" cy="0.2" r="0.45">
      <stop offset="0%" stop-color="#7B3FA0" stop-opacity="0.20"/>
      <stop offset="100%" stop-color="#7B3FA0" stop-opacity="0"/>
    </radialGradient>
    <!-- パープルグロー2: 左下に配置して奥行き -->
    <radialGradient id="glow-purple2" cx="0.1" cy="0.9" r="0.4">
      <stop offset="0%" stop-color="#4A2D99" stop-opacity="0.15"/>
      <stop offset="100%" stop-color="#4A2D99" stop-opacity="0"/>
    </radialGradient>
    <!-- アクセントライン: パープル同系グラデーション -->
    <linearGradient id="accent-line" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#7B3FA0"/>
      <stop offset="100%" stop-color="#4A2D99"/>
    </linearGradient>
  </defs>

  <!-- 背景: 3ストップパープル深度グラデーション -->
  <rect width="960" height="540" fill="url(#bg-dark)"/>

  <!-- パープルグロー装飾（右上） -->
  <circle cx="750" cy="120" r="280" fill="url(#glow-purple)"/>

  <!-- パープルグロー装飾2（左下） -->
  <circle cx="100" cy="480" r="220" fill="url(#glow-purple2)"/>

  <!-- パープル斜線アクセント（右上） -->
  <line x1="880" y1="0" x2="960" y2="140" stroke="#7B3FA0" stroke-width="2" opacity="0.35"/>
  <line x1="920" y1="0" x2="960" y2="70" stroke="#4A2D99" stroke-width="1.5" opacity="0.3"/>

  <!-- タイトル -->
  <text x="80" y="220" font-size="36" font-weight="bold"
        fill="#FFFFFF" font-family="Segoe UI">プレゼンテーションタイトル</text>

  <!-- サブタイトル（マゼンタを単色ポイントとして使用） -->
  <text x="80" y="270" font-size="22"
        fill="#E047A0" font-family="Segoe UI">サブタイトル</text>

  <!-- アクセントライン（パープル同系グラデーション） -->
  <rect x="80" y="286" width="200" height="3" rx="1.5" fill="url(#accent-line)"/>

  <!-- 補足情報 -->
  <text x="80" y="330" font-size="14"
        fill="#C8C0D8" font-family="Segoe UI">補足説明テキストをここに</text>
  <text x="80" y="355" font-size="14"
        fill="#C8C0D8" font-family="Segoe UI">2行目の補足テキスト</text>

  <!-- 日付 -->
  <text x="80" y="490" font-size="14"
        fill="#8B8BA0" font-family="Segoe UI">2026年3月</text>

  <!-- フッター -->
  <text x="880" y="520" font-size="12"
        fill="#8B8BA0" font-family="Segoe UI"
        text-anchor="end">Microsoft Azure</text>
</svg>
```

#### パターン2: 3カラムカード

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 540">
  <defs>
    <!-- ライト背景: ライラック系グラデーション -->
    <linearGradient id="bg-light" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#F5F0FA"/>
      <stop offset="100%" stop-color="#EDE8F5"/>
    </linearGradient>
    <!-- ヘッダーバー: パープル同系 -->
    <linearGradient id="header-grad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#2D1B69"/>
      <stop offset="100%" stop-color="#4A2D99"/>
    </linearGradient>
    <!-- カード背景: 白 → ライラック の微妙なグラデーション -->
    <linearGradient id="card-grad" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="100%" stop-color="#F0ECF5"/>
    </linearGradient>
    <!-- アイコン円1: パープル対角グラデ -->
    <linearGradient id="icon-grad-1" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#2D1B69"/>
      <stop offset="100%" stop-color="#4A2D99"/>
    </linearGradient>
    <!-- アイコン円2: ブルーバイオレット対角グラデ -->
    <linearGradient id="icon-grad-2" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#4A2D99"/>
      <stop offset="100%" stop-color="#7B3FA0"/>
    </linearGradient>
    <!-- アイコン円3: パープルグロー対角グラデ -->
    <linearGradient id="icon-grad-3" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#7B3FA0"/>
      <stop offset="100%" stop-color="#2D1B69"/>
    </linearGradient>
    <!-- 装飾グロー: コンテンツスライドにも必ず入れる -->
    <radialGradient id="glow-corner" cx="0.9" cy="0.85" r="0.35">
      <stop offset="0%" stop-color="#7B3FA0" stop-opacity="0.10"/>
      <stop offset="100%" stop-color="#7B3FA0" stop-opacity="0"/>
    </radialGradient>
  </defs>

  <!-- 背景: ライラック系グラデーション -->
  <rect width="960" height="540" fill="url(#bg-light)"/>

  <!-- 装飾: パープルグロー（右下隅） — コンテンツスライドにも装飾は必須 -->
  <circle cx="870" cy="460" r="200" fill="url(#glow-corner)"/>

  <!-- ヘッダーバー -->
  <rect x="0" y="0" width="960" height="70" fill="url(#header-grad)"/>
  <text x="40" y="46" font-size="24" font-weight="bold"
        fill="#FFFFFF" font-family="Segoe UI">3つのポイント</text>

  <!-- カード1（グラデーション背景 + グラデーションアイコン円） -->
  <rect x="40" y="100" width="270" height="380" rx="12"
        fill="url(#card-grad)" stroke="#D1D5DB"/>
  <circle cx="175" cy="170" r="35" fill="url(#icon-grad-1)"/>
  <text x="175" y="178" font-size="24" fill="#FFFFFF"
        font-family="Segoe UI" text-anchor="middle">1</text>
  <text x="175" y="240" font-size="18" font-weight="bold"
        fill="#1A1A2E" font-family="Segoe UI"
        text-anchor="middle">ポイント1</text>
  <text x="60" y="280" font-size="14"
        fill="#4A4A6A" font-family="Segoe UI">説明テキストを</text>
  <text x="60" y="300" font-size="14"
        fill="#4A4A6A" font-family="Segoe UI">ここに記載する</text>

  <!-- カード2（グラデーション背景 + グラデーションアイコン円） -->
  <rect x="345" y="100" width="270" height="380" rx="12"
        fill="url(#card-grad)" stroke="#D1D5DB"/>
  <circle cx="480" cy="170" r="35" fill="url(#icon-grad-2)"/>
  <text x="480" y="178" font-size="24" fill="#FFFFFF"
        font-family="Segoe UI" text-anchor="middle">2</text>
  <text x="480" y="240" font-size="18" font-weight="bold"
        fill="#1A1A2E" font-family="Segoe UI"
        text-anchor="middle">ポイント2</text>

  <!-- カード3（グラデーション背景 + グラデーションアイコン円） -->
  <rect x="650" y="100" width="270" height="380" rx="12"
        fill="url(#card-grad)" stroke="#D1D5DB"/>
  <circle cx="785" cy="170" r="35" fill="url(#icon-grad-3)"/>
  <text x="785" y="178" font-size="24" fill="#FFFFFF"
        font-family="Segoe UI" text-anchor="middle">3</text>
  <text x="785" y="240" font-size="18" font-weight="bold"
        fill="#1A1A2E" font-family="Segoe UI"
        text-anchor="middle">ポイント3</text>
</svg>
```

#### パターン3: 比較表

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 540">
  <defs>
    <!-- ライト背景 -->
    <linearGradient id="bg-light" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#F5F0FA"/>
      <stop offset="100%" stop-color="#EDE8F5"/>
    </linearGradient>
    <!-- ヘッダーバー -->
    <linearGradient id="header-grad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#2D1B69"/>
      <stop offset="100%" stop-color="#4A2D99"/>
    </linearGradient>
    <!-- 左カラムヘッダー: パープル同系 -->
    <linearGradient id="col-left" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#2D1B69"/>
      <stop offset="100%" stop-color="#4A2D99"/>
    </linearGradient>
    <!-- 右カラムヘッダー: ブルーバイオレット→パープルグロー（パープル同系、アイスクリームにならない） -->
    <linearGradient id="col-right" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#4A2D99"/>
      <stop offset="100%" stop-color="#7B3FA0"/>
    </linearGradient>
    <!-- セル背景: 白 → ライラック -->
    <linearGradient id="cell-grad" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="100%" stop-color="#F0ECF5"/>
    </linearGradient>
    <!-- 装飾グロー -->
    <radialGradient id="glow-decor" cx="0.85" cy="0.8" r="0.3">
      <stop offset="0%" stop-color="#7B3FA0" stop-opacity="0.08"/>
      <stop offset="100%" stop-color="#7B3FA0" stop-opacity="0"/>
    </radialGradient>
  </defs>

  <!-- 背景 -->
  <rect width="960" height="540" fill="url(#bg-light)"/>

  <!-- 装飾グロー（右下） -->
  <circle cx="850" cy="450" r="200" fill="url(#glow-decor)"/>

  <!-- ヘッダーバー -->
  <rect x="0" y="0" width="960" height="70" fill="url(#header-grad)"/>
  <text x="40" y="46" font-size="24" font-weight="bold"
        fill="#FFFFFF" font-family="Segoe UI">比較: A vs B</text>

  <!-- 左カラム（パープル同系グラデ） -->
  <rect x="40" y="100" width="420" height="50" rx="8"
        fill="url(#col-left)"/>
  <text x="250" y="132" font-size="18" font-weight="bold"
        fill="#FFFFFF" font-family="Segoe UI"
        text-anchor="middle">プランA</text>
  <rect x="40" y="155" width="420" height="40"
        fill="url(#cell-grad)" stroke="#D1D5DB"/>
  <text x="60" y="180" font-size="14"
        fill="#1A1A2E" font-family="Segoe UI">特徴1の説明</text>

  <!-- 右カラム（パープル同系グラデ — BV → PG で差をつける） -->
  <rect x="500" y="100" width="420" height="50" rx="8"
        fill="url(#col-right)"/>
  <text x="710" y="132" font-size="18" font-weight="bold"
        fill="#FFFFFF" font-family="Segoe UI"
        text-anchor="middle">プランB</text>
  <rect x="500" y="155" width="420" height="40"
        fill="url(#cell-grad)" stroke="#D1D5DB"/>
  <text x="520" y="180" font-size="14"
        fill="#1A1A2E" font-family="Segoe UI">特徴1の説明</text>
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
- **カラー使用原則を必ず守る** — 1スライド最大5色、パープル同系グラデーションが基本、マゼンタ・シアンは単色ポイント
- **すべての面にグラデーション** — 背景・カード・アイコン円・ピル・バッジ・セルすべてに `<defs>` のグラデーションを使い `fill="url(#id)"` で参照する。`fill="#xxxxxx"` のベタ塗りはテキスト・線以外禁止
- **`<defs>` を SVG の先頭に置く** — グラデーション定義はすべて `<defs>...</defs>` 内にまとめる
- **パープルグロー必須** — **すべてのスライド**（タイトルもコンテンツも）に `radialGradient` で `#7B3FA0` の半透明グローを最低1つ配置
- **マゼンタ→シアン直行禁止** — `#E047A0` → `#00D4FF` の2ストップグラデーションはアイスクリーム感が出るため絶対に使わない。パープル同系（`#2D1B69` → `#7B3FA0`）を使う
- アクセント色（Teal Green `#00B894`）は明確な意図がある場合のみ使用する
- ファイル名は `slide01.svg`, `slide02.svg`, ... の連番
- **ハイパーリンク** — 情報源の URL を `<a>` タグで埋め込む（PPTX でクリック可能になる）

### 🚫 禁止カラー（絶対に使わない）

以下の Azure ブランドカラーは**絶対に使用禁止**。トレーニングデータの影響で出力されがちだが、カスタムパレットのみを使うこと。

| 色名 | Hex | 代わりに使う色 |
|------|-----|---------------|
| Azure Blue | `#0078D4` | `#2D1B69`（Purple Dark）または `#00D4FF`（Cyan） |
| Azure Light Blue | `#50E6FF` | `#00D4FF`（Bright Cyan） |
| Azure Dark Blue | `#005A9E` | `#1A0A2E`（Deep Violet） |
| Azure Pale Blue | `#B4D6F5` | `#F5F0FA`（Lilac Light） |
| Azure Green | `#107C10` | `#00B894`（Teal Green、必要時のみ） |
| Azure Yellow | `#FFB900` | 使用しない |
| Azure Red | `#E81123` | `#E047A0`（Magenta、必要時のみ） |
| Azure Purple | `#8764B8` | `#7B3FA0`（Purple Glow） |
| Deep Navy 系 | `#0D1B2A`, `#1B2A4A`, `#1A3A4A` | 旧テーマ。`#0D0D1A`, `#1A0A2E`, `#2D1B69` を使う |

**判定基準**: `#0078D4`, `#50E6FF`, `#0D1B2A`, `#1B2A4A`, `#1A3A4A` が SVG に含まれていたら**間違い**。必ず上記カスタムパレットの色に置き換える。

### 🚫 禁止グラデーションパターン

| パターン | なぜ NG | 代わりに |
|----------|--------|----------|
| `#E047A0` → `#00D4FF`（2ストップ） | アイスクリームショップ感。ピンク→水色でポップすぎる | `#2D1B69` → `#7B3FA0`（パープル同系） |
| `fill="#FAFBFC"` / `fill="#F0ECF5"` のベタ塗りカード | 平面的で素人感。グラデーションがない | `url(#card-grad)` で `#FFFFFF` → `#F0ECF5` |
| `fill="#2D1B69"` のベタ塗りアイコン円 | 立体感がない | `url(#icon-grad)` で `#2D1B69` → `#4A2D99` |
| 装飾のないコンテンツスライド | タイトルだけ装飾があり、他がフラットだと落差が出る | すべてのスライドに `radialGradient` グローを配置 |

### 🚫 SVG 構造の制約

PPTX 変換の互換性と品質を保つため、以下のルールを厳守する。

**座標の直接指定（必須）:**
- 各要素（`<rect>`, `<text>`, `<circle>` 等）の座標は `x`, `y`, `cx`, `cy` 等の属性で**直接指定**する
- `<g transform="translate(x, y)">` による間接オフセットは**避ける**（svg2pptx.py は対応しているが、デバッグしづらくなるため非推奨）

**スタイル属性の直書き（推奨）:**
- `style="fill: #0D0D1A; stroke: none"` ではなく、`fill="#0D0D1A" stroke="none"` のように属性として直接記述する
- グラデーションの `<stop>` も `stop-color="#0D0D1A"` を属性で書く（`style="stop-color:..."` は避ける）

**OK な例:**
```xml
<rect x="100" y="50" width="200" height="80" fill="url(#grad1)" rx="8"/>
<text x="120" y="90" font-size="16" fill="#F5F0FA">テキスト</text>
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
<text x="30" y="520" font-size="10" fill="#C8C0D8">
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
