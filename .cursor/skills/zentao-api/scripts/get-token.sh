#!/usr/bin/env bash
# 获取禅道 API token，优先使用缓存；切换服务器或手动清除时重新登录。
# 用法：TOKEN=$(bash get-token.sh)
# 依赖：curl, node
# 注：禅道 token 永久有效，仅在 URL 变更或用户手动删除缓存时重新登录。

set -euo pipefail

CACHE_FILE="${HOME}/.zentao-token.json"

# 若已设置 ZENTAO_TOKEN，直接使用，跳过缓存和登录流程
if [[ -n "${ZENTAO_TOKEN:-}" ]]; then
  echo "$ZENTAO_TOKEN"
  exit 0
fi

# 检查必要的环境变量
if [[ -z "${ZENTAO_URL:-}" || -z "${ZENTAO_ACCOUNT:-}" || -z "${ZENTAO_PASSWORD:-}" ]]; then
  echo "错误：请先设置环境变量 ZENTAO_URL、ZENTAO_ACCOUNT、ZENTAO_PASSWORD" >&2
  exit 1
fi

# 尝试从缓存读取 token（仅校验 URL 是否匹配）
if [[ -f "$CACHE_FILE" ]]; then
  CACHED=$(node - "$CACHE_FILE" "$ZENTAO_URL" <<'JSEOF'
const [,, cachePath, currentUrl] = process.argv;
try {
  const fs = require('fs');
  const data = JSON.parse(fs.readFileSync(cachePath, 'utf8'));
  if (data.url === currentUrl && data.token) {
    process.stdout.write(data.token);
  }
} catch (e) {}
JSEOF
  )
  if [[ -n "$CACHED" ]]; then
    echo "$CACHED"
    exit 0
  fi
fi

# 缓存不存在或 URL 已变更，重新登录
RESPONSE=$(curl -s -X POST "${ZENTAO_URL}/api.php/v2/users/login" \
  -H "Content-Type: application/json" \
  -d "{\"account\": \"${ZENTAO_ACCOUNT}\", \"password\": \"${ZENTAO_PASSWORD}\"}")

TOKEN=$(echo "$RESPONSE" | node -e "
const chunks = [];
process.stdin.on('data', d => chunks.push(d));
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(chunks.join(''));
    const token = (data.data && data.data.token) || data.token || '';
    if (!token) {
      process.stderr.write('登录失败，服务器响应：' + JSON.stringify(data) + '\n');
      process.exit(1);
    }
    process.stdout.write(token);
  } catch (e) {
    process.stderr.write('解析登录响应失败：' + e.message + '\n');
    process.exit(1);
  }
});
") || { echo "错误：登录失败，请查看上方错误信息" >&2; exit 1; }

# 写入缓存
node - "$CACHE_FILE" "$TOKEN" "$ZENTAO_URL" <<'JSEOF'
const [,, cachePath, token, url] = process.argv;
const fs = require('fs');
fs.writeFileSync(cachePath, JSON.stringify({ token, url }));
JSEOF

echo "$TOKEN"
