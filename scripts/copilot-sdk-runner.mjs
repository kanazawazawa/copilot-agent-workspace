#!/usr/bin/env node
// =============================================================
// Copilot SDK Runner
// =============================================================
// Copilot CLI を SDK 経由でプログラマティックに呼び出すスクリプト。
// GitHub Actions ワークフローから実行される。
//
// 環境変数:
//   COPILOT_GITHUB_TOKEN   - GitHub PAT（Copilot 権限付き）
//   COPILOT_PROMPT         - 実行するプロンプト
//   COPILOT_MODEL          - 使用するモデル（デフォルト: claude-opus-4.6）
//   COPILOT_MAX_RETRIES    - 最大試行回数（デフォルト: 2 = 初回 + リトライ1回）
//   COPILOT_RETRY_DELAY    - リトライ待機秒数（デフォルト: 10）
//   COPILOT_TIMEOUT_MS     - sendAndWait タイムアウト ms（デフォルト: 600000 = 10分）
//
// 使い方:
//   COPILOT_GITHUB_TOKEN=xxx COPILOT_PROMPT="..." node scripts/copilot-sdk-runner.mjs
// =============================================================

import { CopilotClient } from "@github/copilot-sdk";

// --- 設定 ---
const prompt = process.env.COPILOT_PROMPT;
const model = process.env.COPILOT_MODEL || "claude-opus-4.6";
const maxRetries = parseInt(process.env.COPILOT_MAX_RETRIES || "2", 10); // 最大試行回数（デフォルト2 = 初回 + リトライ1回）
const retryDelaySec = parseInt(process.env.COPILOT_RETRY_DELAY || "10", 10); // リトライ待機秒数
const timeoutMs = parseInt(process.env.COPILOT_TIMEOUT_MS || "600000", 10); // タイムアウト（デフォルト10分）

if (!prompt) {
  console.error("❌ COPILOT_PROMPT 環境変数が設定されていません");
  process.exit(1);
}

if (!process.env.COPILOT_GITHUB_TOKEN) {
  console.error("❌ COPILOT_GITHUB_TOKEN 環境変数が設定されていません");
  process.exit(1);
}

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

console.log("🤖 Copilot SDK Runner");
console.log(`📝 Prompt: ${prompt}`);
console.log(`🧠 Model: ${model}`);
console.log(`🔄 Max retries: ${maxRetries}（初回含む）`);
console.log(`⏱️  Timeout: ${timeoutMs / 1000}s`);
console.log("");

// --- SDK クライアント初期化 ---
// COPILOT_GITHUB_TOKEN は SDK が自動で読み取る
const client = new CopilotClient();

try {
  let response = null;
  let lastError = null;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      // --- セッション作成 ---
      console.log(`📡 [${attempt}/${maxRetries}] セッション作成中...`);
      const session = await client.createSession({
        model,
        // --allow-all 相当: すべてのツール実行を自動承認
        onPermissionRequest: async (request) => {
          console.log(`🔧 Tool permission: ${request.toolName ?? "unknown"} → approved`);
          return { kind: "approved" };
        },
      });
      console.log("✅ セッション作成完了");

      // --- プロンプト送信 & 完了待ち ---
      console.log("🚀 プロンプト送信中...");
      response = await session.sendAndWait(
        { prompt },
        timeoutMs
      );

      // --- クリーンアップ ---
      await session.destroy();

      if (response) {
        console.log("");
        console.log("=".repeat(60));
        console.log("📄 Response:");
        console.log("=".repeat(60));
        console.log(response.data.content);
        console.log(`✅ セッション終了（attempt ${attempt}/${maxRetries} で成功）`);
        break; // 成功 → ループ脱出
      } else {
        throw new Error("レスポンスが空でした");
      }
    } catch (err) {
      lastError = err;
      console.error(`⚠️ [${attempt}/${maxRetries}] 失敗: ${err.message}`);

      if (attempt < maxRetries) {
        console.log(`⏳ ${retryDelaySec}秒後にリトライします...`);
        await sleep(retryDelaySec * 1000);
      }
    }
  }

  // すべてリトライ失敗
  if (!response) {
    console.error(`❌ ${maxRetries}回すべて失敗しました`);
    if (lastError) {
      console.error("最後のエラー:", lastError.message);
      console.error(lastError.stack);
    }
    process.exitCode = 1;
  }
} catch (error) {
  console.error("❌ 予期しないエラー:", error.message);
  console.error(error.stack);
  process.exitCode = 1;
} finally {
  await client.stop();
  process.exit(process.exitCode || 0);
}
