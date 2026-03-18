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
YELLOW='\033[0;33m'
RESET='\033[0m'

pass() { echo -e "  ${GREEN}✓ $1${RESET}"; PASS=$((PASS + 1)); }
fail() { echo -e "  ${RED}✗ $1${RESET}"; FAIL=$((FAIL + 1)); }

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

# 运行被测脚本，结果写入 OUTPUT 和 EXIT_CODE
run_script() {
  EXIT_CODE=0
  OUTPUT=$(HOME="$FAKE_HOME" PATH="$MOCK_BIN:$PATH" bash "$SCRIPT" 2>&1) || EXIT_CODE=$?
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
fs.writeFileSync(
  '$FAKE_HOME/.zentao-token.json',
  JSON.stringify({ token: '$token', url: '$url', account: '$account' }, null, 2)
);"
}

# 读取缓存全部字段（逐行输出 token / url / account）
read_cache() {
  node -e "
try {
  const d = JSON.parse(require('fs').readFileSync('$FAKE_HOME/.zentao-token.json', 'utf8'));
  process.stdout.write((d.token||'') + '\n' + (d.url||'') + '\n' + (d.account||'') + '\n');
} catch(e) { process.stdout.write('\n\n\n'); }"
}

# 重置所有 ZENTAO_* 环境变量
reset_env() {
  unset ZENTAO_URL ZENTAO_ACCOUNT ZENTAO_PASSWORD ZENTAO_TOKEN 2>/dev/null || true
}

# 从 KEY=VALUE 输出中提取指定字段的值
get_field() {
  local line
  line=$(echo "$OUTPUT" | grep "^${1}=")
  echo "${line#*=}"
}

echo ""
echo "▶ get-token.sh 测试套件"
echo "══════════════════════════════════════════════"

# ───────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}── 优先级 1：缓存文件 ──────────────────────────${RESET}"

# ── Test 1: 缓存命中（URL + account 均匹配） ────────
echo ""
echo "[1] 缓存命中：直接返回缓存 token"
reset_env
export ZENTAO_URL="http://zentao.test"
export ZENTAO_ACCOUNT="admin"
export ZENTAO_PASSWORD="password"
rm -f "$FAKE_HOME/.zentao-token.json"
write_cache "cached_token_abc" "http://zentao.test" "admin"
mock_curl '{"unexpected": "curl_was_called"}'
run_script
_tok=$(get_field ZENTAO_TOKEN) _url=$(get_field ZENTAO_URL) _acc=$(get_field ZENTAO_ACCOUNT)
if [[ "$_tok" == "cached_token_abc" && "$_url" == "http://zentao.test" && "$_acc" == "admin" && "$EXIT_CODE" -eq 0 ]]; then
  pass "直接返回缓存 token/url/account，未调用登录 API"
else
  fail "应返回 cached_token_abc / http://zentao.test / admin（exit=0），实际：$OUTPUT（exit=$EXIT_CODE）"
fi

# ── Test 2: 缓存有效时无需 ZENTAO_PASSWORD（核心修复点） ──
echo ""
echo "[2] 缓存有效时无需 ZENTAO_PASSWORD"
reset_env
export ZENTAO_URL="http://zentao.test"
export ZENTAO_ACCOUNT="admin"
# 不设置 ZENTAO_PASSWORD
rm -f "$FAKE_HOME/.zentao-token.json"
write_cache "no_password_token" "http://zentao.test" "admin"
mock_curl '{"unexpected": "curl_was_called"}'
run_script
_tok=$(get_field ZENTAO_TOKEN)
if [[ "$_tok" == "no_password_token" && "$EXIT_CODE" -eq 0 ]]; then
  pass "缓存有效时无需密码，直接返回 token"
else
  fail "应返回 no_password_token（exit=0），实际：$OUTPUT（exit=$EXIT_CODE）"
fi

# ── Test 3: 缓存自动补全 URL/account，无需任何环境变量 ──
echo ""
echo "[3] 缓存补全 ZENTAO_URL/ACCOUNT，无需环境变量和密码"
reset_env
rm -f "$FAKE_HOME/.zentao-token.json"
write_cache "auto_filled_token" "http://zentao.test" "admin"
mock_curl '{"unexpected": "curl_was_called"}'
run_script
_tok=$(get_field ZENTAO_TOKEN) _url=$(get_field ZENTAO_URL) _acc=$(get_field ZENTAO_ACCOUNT)
if [[ "$_tok" == "auto_filled_token" && "$_url" == "http://zentao.test" && "$_acc" == "admin" && "$EXIT_CODE" -eq 0 ]]; then
  pass "URL/account 从缓存补全，直接返回缓存 token，无需密码"
else
  fail "应返回 auto_filled_token / http://zentao.test / admin（exit=0），实际：$OUTPUT（exit=$EXIT_CODE）"
fi

# ── Test 4: 缓存 URL 不匹配，重新登录 ───────────────
echo ""
echo "[4] 缓存 URL 不匹配，重新登录"
reset_env
export ZENTAO_URL="http://zentao.test"
export ZENTAO_ACCOUNT="admin"
export ZENTAO_PASSWORD="password"
rm -f "$FAKE_HOME/.zentao-token.json"
write_cache "other_server_token" "http://other-server.test" "admin"
mock_curl '{"data": {"token": "new_server_token"}}'
run_script
_tok=$(get_field ZENTAO_TOKEN)
if [[ "$_tok" == "new_server_token" && "$EXIT_CODE" -eq 0 ]]; then
  pass "URL 不匹配时重新登录，返回新 token"
else
  fail "应返回 new_server_token，实际：$OUTPUT（exit=$EXIT_CODE）"
fi

# ── Test 5: 缓存 account 不匹配，重新登录 ───────────
echo ""
echo "[5] 缓存账号不匹配，重新登录"
reset_env
export ZENTAO_URL="http://zentao.test"
export ZENTAO_ACCOUNT="admin"
export ZENTAO_PASSWORD="password"
rm -f "$FAKE_HOME/.zentao-token.json"
write_cache "other_user_token" "http://zentao.test" "other_user"
mock_curl '{"data": {"token": "new_account_token"}}'
run_script
_tok=$(get_field ZENTAO_TOKEN)
if [[ "$_tok" == "new_account_token" && "$EXIT_CODE" -eq 0 ]]; then
  pass "账号不匹配时重新登录，返回新 token"
else
  fail "应返回 new_account_token，实际：$OUTPUT（exit=$EXIT_CODE）"
fi

# ── Test 6: 缓存 JSON 损坏，降级重新登录 ────────────
echo ""
echo "[6] 缓存 JSON 损坏，自动降级重新登录"
reset_env
export ZENTAO_URL="http://zentao.test"
export ZENTAO_ACCOUNT="admin"
export ZENTAO_PASSWORD="password"
echo "not valid json {{{" > "$FAKE_HOME/.zentao-token.json"
mock_curl '{"data": {"token": "recovered_token"}}'
run_script
_tok=$(get_field ZENTAO_TOKEN)
if [[ "$_tok" == "recovered_token" && "$EXIT_CODE" -eq 0 ]]; then
  pass "缓存损坏时自动降级重新登录"
else
  fail "应返回 recovered_token，实际：$OUTPUT（exit=$EXIT_CODE）"
fi

# ───────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}── 优先级 2：ZENTAO_TOKEN 环境变量 ─────────────${RESET}"

# ── Test 7: ZENTAO_TOKEN 生效（无缓存） ─────────────
echo ""
echo "[7] ZENTAO_TOKEN 环境变量生效（无缓存）"
reset_env
rm -f "$FAKE_HOME/.zentao-token.json"
mock_curl '{"unexpected": "curl_was_called"}'
EXIT_CODE=0
OUTPUT=$(ZENTAO_TOKEN="env_token_value" ZENTAO_URL="http://zentao.test" \
  HOME="$FAKE_HOME" PATH="$MOCK_BIN:$PATH" bash "$SCRIPT" 2>&1) || EXIT_CODE=$?
_tok=$(get_field ZENTAO_TOKEN) _url=$(get_field ZENTAO_URL)
if [[ "$_tok" == "env_token_value" && "$_url" == "http://zentao.test" && "$EXIT_CODE" -eq 0 ]]; then
  pass "ZENTAO_TOKEN 直接返回，不调用登录 API"
else
  fail "应返回 env_token_value / http://zentao.test（exit=0），实际：$OUTPUT（exit=$EXIT_CODE）"
fi

# ── Test 7b: ZENTAO_TOKEN 路径写入缓存 ──────────────
echo ""
echo "[7b] ZENTAO_TOKEN 路径：成功后写入缓存"
reset_env
rm -f "$FAKE_HOME/.zentao-token.json"
EXIT_CODE=0
OUTPUT=$(ZENTAO_TOKEN="env_token_value" ZENTAO_URL="http://zentao.test" ZENTAO_ACCOUNT="admin" \
  HOME="$FAKE_HOME" PATH="$MOCK_BIN:$PATH" bash "$SCRIPT" 2>&1) || EXIT_CODE=$?
if [[ -f "$FAKE_HOME/.zentao-token.json" ]]; then
  mapfile -t _fields < <(read_cache)
  _ct="${_fields[0]:-}" _cu="${_fields[1]:-}" _ca="${_fields[2]:-}"
  if [[ "$_ct" == "env_token_value" && "$_cu" == "http://zentao.test" && "$_ca" == "admin" ]]; then
    pass "ZENTAO_TOKEN 路径写入缓存，下次无需环境变量"
  else
    fail "缓存内容不匹配：token=$_ct url=$_cu account=$_ca"
  fi
else
  fail "ZENTAO_TOKEN 路径应创建缓存文件"
fi

# ── Test 8: 缓存优先于 ZENTAO_TOKEN ─────────────────
echo ""
echo "[8] 缓存 token 优先于 ZENTAO_TOKEN 环境变量"
reset_env
rm -f "$FAKE_HOME/.zentao-token.json"
write_cache "cache_wins_token" "http://zentao.test" "admin"
mock_curl '{"unexpected": "curl_was_called"}'
EXIT_CODE=0
OUTPUT=$(ZENTAO_TOKEN="env_token_value" ZENTAO_URL="http://zentao.test" ZENTAO_ACCOUNT="admin" \
  HOME="$FAKE_HOME" PATH="$MOCK_BIN:$PATH" bash "$SCRIPT" 2>&1) || EXIT_CODE=$?
_tok=$(get_field ZENTAO_TOKEN)
if [[ "$_tok" == "cache_wins_token" && "$EXIT_CODE" -eq 0 ]]; then
  pass "缓存 token 优先于 ZENTAO_TOKEN 环境变量"
else
  fail "应返回 cache_wins_token（缓存优先），实际：$OUTPUT（exit=$EXIT_CODE）"
fi

# ───────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}── 优先级 3：账号密码登录 ───────────────────────${RESET}"

reset_env
export ZENTAO_URL="http://zentao.test"
export ZENTAO_ACCOUNT="admin"
export ZENTAO_PASSWORD="password"

# ── Test 9: 登录响应含 data.token 字段 ────────────
echo ""
echo "[9] 登录响应：data.token 字段"
rm -f "$FAKE_HOME/.zentao-token.json"
mock_curl '{"data": {"token": "nested_token"}}'
run_script
_tok=$(get_field ZENTAO_TOKEN)
if [[ "$_tok" == "nested_token" && "$EXIT_CODE" -eq 0 ]]; then
  pass "识别 data.token 嵌套字段"
else
  fail "应返回 nested_token，实际：$OUTPUT（exit=$EXIT_CODE）"
fi

# ── Test 10: 登录响应含顶层 token 字段 ─────────────
echo ""
echo "[10] 登录响应：顶层 token 字段"
rm -f "$FAKE_HOME/.zentao-token.json"
mock_curl '{"token": "toplevel_token"}'
run_script
_tok=$(get_field ZENTAO_TOKEN)
if [[ "$_tok" == "toplevel_token" && "$EXIT_CODE" -eq 0 ]]; then
  pass "识别顶层 token 字段"
else
  fail "应返回 toplevel_token，实际：$OUTPUT（exit=$EXIT_CODE）"
fi

# ── Test 11: 登录失败（响应无 token 字段） ──────────
echo ""
echo "[11] 登录失败：响应无 token 字段"
rm -f "$FAKE_HOME/.zentao-token.json"
mock_curl '{"error": "invalid credentials"}'
run_script
if echo "$OUTPUT" | grep -q "登录失败" && [[ "$EXIT_CODE" -ne 0 ]]; then
  pass "打印错误信息并以非零退出码退出"
else
  fail "应打印登录失败且退出码非零；output=$OUTPUT exit=$EXIT_CODE"
fi

# ── Test 12: 登录返回非 JSON ────────────────────────
echo ""
echo "[12] 登录返回非 JSON 响应"
rm -f "$FAKE_HOME/.zentao-token.json"
mock_curl 'not json at all'
run_script
if echo "$OUTPUT" | grep -q "解析登录响应失败" && [[ "$EXIT_CODE" -ne 0 ]]; then
  pass "打印解析错误信息并以非零退出码退出"
else
  fail "应打印解析错误且退出码非零；output=$OUTPUT exit=$EXIT_CODE"
fi

# ───────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}── 兜底：缺失必要信息 ───────────────────────────${RESET}"

# ── Test 13a: ZENTAO_TOKEN 设置但缺少 ZENTAO_URL ────
echo ""
echo "[13a] ZENTAO_TOKEN 已设置但缺少 ZENTAO_URL"
reset_env
rm -f "$FAKE_HOME/.zentao-token.json"
EXIT_CODE=0
OUTPUT=$(ZENTAO_TOKEN="some_token" HOME="$FAKE_HOME" PATH="$MOCK_BIN:$PATH" bash "$SCRIPT" 2>&1) || EXIT_CODE=$?
if echo "$OUTPUT" | grep -q "ZENTAO_URL" && [[ "$EXIT_CODE" -ne 0 ]]; then
  pass "缺少 ZENTAO_URL 时打印错误提示并非零退出"
else
  fail "应提示缺少 ZENTAO_URL 且退出码非零；output=$OUTPUT exit=$EXIT_CODE"
fi

# ── Test 13: 无缓存、无 ZENTAO_TOKEN、无账号密码 ────
echo ""
echo "[13] 无任何鉴权信息，打印兜底提示"
reset_env
rm -f "$FAKE_HOME/.zentao-token.json"
run_script
if echo "$OUTPUT" | grep -q "Token 获取失败" && [[ "$EXIT_CODE" -ne 0 ]]; then
  pass "打印兜底错误提示并以非零退出码退出"
else
  fail "应打印 Token 获取失败且退出码非零；output=$OUTPUT exit=$EXIT_CODE"
fi

# ── Test 14: 有 URL/account 但缺 PASSWORD，无缓存 ───
echo ""
echo "[14] 有 ZENTAO_URL/ACCOUNT 但缺 ZENTAO_PASSWORD，无缓存"
reset_env
export ZENTAO_URL="http://zentao.test"
export ZENTAO_ACCOUNT="admin"
rm -f "$FAKE_HOME/.zentao-token.json"
run_script
if echo "$OUTPUT" | grep -q "Token 获取失败" && [[ "$EXIT_CODE" -ne 0 ]]; then
  pass "缺少 PASSWORD 时打印错误提示"
else
  fail "应打印 Token 获取失败且退出码非零；output=$OUTPUT exit=$EXIT_CODE"
fi

# ───────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}── 缓存写入 ─────────────────────────────────────${RESET}"

reset_env
export ZENTAO_URL="http://zentao.test"
export ZENTAO_ACCOUNT="admin"
export ZENTAO_PASSWORD="password"

# ── Test 15: 登录后写入 token、url、account ─────────
echo ""
echo "[15] 登录后正确写入缓存（含 token、url、account）"
rm -f "$FAKE_HOME/.zentao-token.json"
mock_curl '{"data": {"token": "written_token"}}'
run_script
_out_tok=$(get_field ZENTAO_TOKEN) _out_url=$(get_field ZENTAO_URL) _out_acc=$(get_field ZENTAO_ACCOUNT)
if [[ -f "$FAKE_HOME/.zentao-token.json" ]]; then
  mapfile -t _fields < <(read_cache)
  _ct="${_fields[0]:-}" _cu="${_fields[1]:-}" _ca="${_fields[2]:-}"
  if [[ "$_ct" == "written_token" && "$_cu" == "http://zentao.test" && "$_ca" == "admin" \
     && "$_out_tok" == "written_token" && "$_out_url" == "http://zentao.test" && "$_out_acc" == "admin" ]]; then
    pass "token、url、account 均已正确写入缓存，且输出一致"
  else
    fail "缓存或输出不匹配：cache=($\_ct/$_cu/$_ca) output=($\_out_tok/$_out_url/$_out_acc)"
  fi
else
  fail "登录成功后应创建缓存文件"
fi

# ── Test 16: 连续两次调用，第二次命中缓存 ──────────
echo ""
echo "[16] 连续调用：第二次命中缓存"
rm -f "$FAKE_HOME/.zentao-token.json"
mock_curl '{"data": {"token": "first_login_token"}}'
run_script
FIRST_TOK=$(get_field ZENTAO_TOKEN)

mock_curl 'SHOULD_NOT_CALL'
run_script
SECOND_TOK=$(get_field ZENTAO_TOKEN)

if [[ "$FIRST_TOK" == "first_login_token" && "$SECOND_TOK" == "first_login_token" && "$EXIT_CODE" -eq 0 ]]; then
  pass "第二次调用命中缓存，token 一致"
else
  fail "first=$FIRST_TOK second=$SECOND_TOK exit=$EXIT_CODE"
fi

# ───────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════"
printf "结果：%d 通过 / %d 总计\n" "$PASS" "$((PASS + FAIL))"
if [[ $FAIL -gt 0 ]]; then
  echo -e "${RED}${FAIL} 个测试失败${RESET}"
  exit 1
else
  echo -e "${GREEN}全部通过${RESET}"
fi
