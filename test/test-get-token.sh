#!/usr/bin/env bash
# 测试 get-token.sh 的各种场景
# 用法：bash test/test-get-token.sh

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$REPO_DIR/skills/zentao-api/scripts/get-token.sh"

# 使用临时目录隔离测试，避免污染真实的 ~/.zentao-token.json
TEMP_DIR=$(mktemp -d)
MOCK_BIN="$TEMP_DIR/bin"
FAKE_HOME="$TEMP_DIR/home"
mkdir -p "$MOCK_BIN" "$FAKE_HOME"

PASS=0
FAIL=0

GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

pass() { echo -e "  ${GREEN}✓ $1${RESET}"; PASS=$((PASS + 1)); }
fail() { echo -e "  ${RED}✗ $1${RESET}"; FAIL=$((FAIL + 1)); }

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

# 运行被测脚本，注入 mock bin 和隔离的 HOME
run_script() {
  HOME="$FAKE_HOME" PATH="$MOCK_BIN:$PATH" bash "$SCRIPT" "$@"
}

# 写入 mock curl，输出固定响应
mock_curl() {
  local response="$1"
  cat > "$MOCK_BIN/curl" << MOCK
#!/usr/bin/env bash
echo '$response'
MOCK
  chmod +x "$MOCK_BIN/curl"
}

# 写入测试用缓存（token + url + account）
write_cache() {
  local token="$1" url="$2" account="$3"
  node -e "
    const fs = require('fs');
    fs.writeFileSync('$FAKE_HOME/.zentao-token.json',
      JSON.stringify({ token: '$token', url: '$url', account: '$account' }));
  "
}

# ──────────────────────────────────────────────
echo ""
echo "▶ get-token.sh 测试套件"
echo "──────────────────────────────────────────────"

# ── Test 1: ZENTAO_TOKEN 直接返回，跳过一切 ───
echo ""
echo "[1] ZENTAO_TOKEN 环境变量直接生效"
unset ZENTAO_URL ZENTAO_ACCOUNT ZENTAO_PASSWORD 2>/dev/null || true
rm -f "$FAKE_HOME/.zentao-token.json"
mock_curl '{"unexpected": "curl_was_called"}'
OUTPUT=$(ZENTAO_TOKEN="direct_token_value" HOME="$FAKE_HOME" PATH="$MOCK_BIN:$PATH" bash "$SCRIPT" 2>&1)
if [[ "$OUTPUT" == "direct_token_value" ]]; then
  pass "ZENTAO_TOKEN 设置时直接输出，不调用登录 API"
else
  fail "应返回 direct_token_value，实际：$OUTPUT"
fi

# ── Test 2: 缺少所有环境变量且无缓存 ──────────
echo ""
echo "[2] 缺少环境变量且无缓存"
unset ZENTAO_URL ZENTAO_ACCOUNT ZENTAO_PASSWORD 2>/dev/null || true
rm -f "$FAKE_HOME/.zentao-token.json"
OUTPUT=$(HOME="$FAKE_HOME" PATH="$MOCK_BIN:$PATH" bash "$SCRIPT" 2>&1 || true)
if echo "$OUTPUT" | grep -q "请先设置环境变量"; then
  pass "打印错误提示并退出"
else
  fail "应提示设置环境变量，实际输出：$OUTPUT"
fi

# ── Test 3: 从缓存自动补全 URL 和 account ─────
echo ""
echo "[3] 从缓存自动补全 ZENTAO_URL 和 ZENTAO_ACCOUNT"
unset ZENTAO_URL ZENTAO_ACCOUNT 2>/dev/null || true
export ZENTAO_PASSWORD="password"
rm -f "$FAKE_HOME/.zentao-token.json"
write_cache "auto_filled_token" "http://zentao.test" "admin"
mock_curl '{"unexpected": "curl_was_called"}'
OUTPUT=$(HOME="$FAKE_HOME" PATH="$MOCK_BIN:$PATH" bash "$SCRIPT" 2>&1)
if [[ "$OUTPUT" == "auto_filled_token" ]]; then
  pass "URL 和 account 从缓存自动补全，直接返回缓存 token"
else
  fail "应返回 auto_filled_token，实际：$OUTPUT"
fi

# 后续测试设置固定环境变量
export ZENTAO_URL="http://zentao.test"
export ZENTAO_ACCOUNT="admin"
export ZENTAO_PASSWORD="password"

# ── Test 4: 缓存命中（URL + account 均匹配）──
echo ""
echo "[4] 缓存命中"
rm -f "$FAKE_HOME/.zentao-token.json"
write_cache "cached_token_abc" "http://zentao.test" "admin"
mock_curl '{"unexpected": "curl_was_called"}'
OUTPUT=$(run_script 2>&1)
if [[ "$OUTPUT" == "cached_token_abc" ]]; then
  pass "直接返回缓存 token，未调用登录 API"
else
  fail "应返回 cached_token_abc，实际：$OUTPUT"
fi

# ── Test 5: 缓存 URL 不匹配，重新登录 ─────────
echo ""
echo "[5] 缓存 URL 不匹配"
rm -f "$FAKE_HOME/.zentao-token.json"
write_cache "other_server_token" "http://other-server.test" "admin"
mock_curl '{"data": {"token": "new_server_token"}}'
OUTPUT=$(run_script 2>&1)
if [[ "$OUTPUT" == "new_server_token" ]]; then
  pass "URL 不匹配时重新登录"
else
  fail "应返回 new_server_token，实际：$OUTPUT"
fi

# ── Test 6: 缓存 account 不匹配，重新登录 ─────
echo ""
echo "[6] 缓存账号不匹配"
rm -f "$FAKE_HOME/.zentao-token.json"
write_cache "other_user_token" "http://zentao.test" "other_user"
mock_curl '{"data": {"token": "new_account_token"}}'
OUTPUT=$(run_script 2>&1)
if [[ "$OUTPUT" == "new_account_token" ]]; then
  pass "账号不匹配时重新登录"
else
  fail "应返回 new_account_token，实际：$OUTPUT"
fi

# ── Test 7: 缓存文件 JSON 损坏，降级重新登录 ──
echo ""
echo "[7] 缓存 JSON 损坏"
echo "not valid json {{{" > "$FAKE_HOME/.zentao-token.json"
mock_curl '{"data": {"token": "recovered_token"}}'
OUTPUT=$(run_script 2>&1)
if [[ "$OUTPUT" == "recovered_token" ]]; then
  pass "缓存损坏时自动降级重新登录"
else
  fail "应返回 recovered_token，实际：$OUTPUT"
fi

# ── Test 8: 登录响应含顶层 token 字段 ─────────
echo ""
echo "[8] 登录响应：顶层 token 字段"
rm -f "$FAKE_HOME/.zentao-token.json"
mock_curl '{"token": "toplevel_token"}'
OUTPUT=$(run_script 2>&1)
if [[ "$OUTPUT" == "toplevel_token" ]]; then
  pass "识别顶层 token 字段"
else
  fail "应返回 toplevel_token，实际：$OUTPUT"
fi

# ── Test 9: 登录响应含 data.token 字段 ────────
echo ""
echo "[9] 登录响应：data.token 字段"
rm -f "$FAKE_HOME/.zentao-token.json"
mock_curl '{"data": {"token": "nested_token"}}'
OUTPUT=$(run_script 2>&1)
if [[ "$OUTPUT" == "nested_token" ]]; then
  pass "识别 data.token 嵌套字段"
else
  fail "应返回 nested_token，实际：$OUTPUT"
fi

# ── Test 10: 登录失败（响应无 token）──────────
echo ""
echo "[10] 登录失败（无 token）"
rm -f "$FAKE_HOME/.zentao-token.json"
mock_curl '{"error": "invalid credentials"}'
OUTPUT=$(run_script 2>&1 || true)
EXIT_CODE=$(HOME="$FAKE_HOME" PATH="$MOCK_BIN:$PATH" bash "$SCRIPT"; echo $?) || EXIT_CODE=$?
if echo "$OUTPUT" | grep -q "登录失败" && [[ "$EXIT_CODE" != "0" ]]; then
  pass "打印错误信息并以非零退出"
else
  fail "应打印登录失败且退出码非零；output=$OUTPUT exit=$EXIT_CODE"
fi

# ── Test 11: 登录返回非 JSON ───────────────────
echo ""
echo "[11] 登录返回非 JSON"
rm -f "$FAKE_HOME/.zentao-token.json"
mock_curl 'not json at all'
OUTPUT=$(run_script 2>&1 || true)
EXIT_CODE=$(HOME="$FAKE_HOME" PATH="$MOCK_BIN:$PATH" bash "$SCRIPT"; echo $?) || EXIT_CODE=$?
if echo "$OUTPUT" | grep -q "解析登录响应失败" && [[ "$EXIT_CODE" != "0" ]]; then
  pass "打印解析错误信息并以非零退出"
else
  fail "应打印解析错误且退出码非零；output=$OUTPUT exit=$EXIT_CODE"
fi

# ── Test 12: 登录成功后写入 token、url、account ─
echo ""
echo "[12] 登录后写入缓存（含 url 和 account）"
rm -f "$FAKE_HOME/.zentao-token.json"
mock_curl '{"data": {"token": "written_token"}}'
run_script > /dev/null 2>&1 || true
if [[ -f "$FAKE_HOME/.zentao-token.json" ]]; then
  CACHE_TOKEN=$(node -e "const d=JSON.parse(require('fs').readFileSync('$FAKE_HOME/.zentao-token.json','utf8')); process.stdout.write(d.token)")
  CACHE_URL=$(node -e "const d=JSON.parse(require('fs').readFileSync('$FAKE_HOME/.zentao-token.json','utf8')); process.stdout.write(d.url)")
  CACHE_ACCOUNT=$(node -e "const d=JSON.parse(require('fs').readFileSync('$FAKE_HOME/.zentao-token.json','utf8')); process.stdout.write(d.account)")
  if [[ "$CACHE_TOKEN" == "written_token" && "$CACHE_URL" == "http://zentao.test" && "$CACHE_ACCOUNT" == "admin" ]]; then
    pass "token、url、account 均已正确写入缓存"
  else
    fail "缓存内容不匹配：token=$CACHE_TOKEN url=$CACHE_URL account=$CACHE_ACCOUNT"
  fi
else
  fail "登录成功后应创建缓存文件"
fi

# ── Test 13: 连续两次调用，第二次命中缓存 ─────
echo ""
echo "[13] 连续调用：第二次命中缓存"
rm -f "$FAKE_HOME/.zentao-token.json"
mock_curl '{"data": {"token": "first_login_token"}}'
FIRST=$(run_script 2>&1)

mock_curl 'SHOULD_NOT_CALL'
SECOND=$(run_script 2>&1)

if [[ "$FIRST" == "first_login_token" && "$SECOND" == "first_login_token" ]]; then
  pass "第二次调用命中缓存，token 一致"
else
  fail "first=$FIRST second=$SECOND"
fi

# ── 结果汇总 ──────────────────────────────────
echo ""
echo "──────────────────────────────────────────────"
echo "结果：${PASS} 通过 / $((PASS + FAIL)) 总计"
if [[ $FAIL -gt 0 ]]; then
  echo -e "${RED}${FAIL} 个测试失败${RESET}"
  exit 1
else
  echo -e "${GREEN}全部通过${RESET}"
fi
