#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../"

if [[ -z "${API_DEEPSEEK_KEY:-}" ]]; then
  echo "Set API_DEEPSEEK_KEY env var or pass: API_DEEPSEEK_KEY=sk-... ./scripts/deploy.sh"
  exit 1
fi

npx wrangler whoami
printf '%s' "$API_DEEPSEEK_KEY" | npx wrangler secret put API_DEEPSEEK_KEY
npx wrangler deploy

echo "Update Info.plist HyperliquidDrinkSmarterAPIBaseURL with your workers.dev URL."
