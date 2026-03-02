#!/usr/bin/env bash

set -e

WORKSPACE_PATH=/workspaces/typo3-devcontainer
PASS=0
FAIL=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

assert_equals() {
  local description="$1"
  local expected="$2"
  local actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo -e "${GREEN}PASS${NC}: $description"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}FAIL${NC}: $description (expected: '$expected', got: '$actual')"
    FAIL=$((FAIL + 1))
  fi
}

assert_success() {
  local description="$1"
  shift
  if "$@" > /dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC}: $description"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}FAIL${NC}: $description (command failed: $*)"
    FAIL=$((FAIL + 1))
  fi
}

assert_contains() {
  local description="$1"
  local needle="$2"
  local haystack="$3"
  if echo "$haystack" | grep -q "$needle"; then
    echo -e "${GREEN}PASS${NC}: $description"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}FAIL${NC}: $description (expected to contain: '$needle')"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== DevContainer Test Suite ==="
echo ""

# --- MariaDB Tests ---
echo "--- MariaDB Service ---"

assert_success "MariaDB is reachable on localhost:3306" \
  php -r "new PDO('mysql:host=127.0.0.1;port=3306', 'typo3', 'typo3');"

DB_EXISTS=$(php -r "
  \$pdo = new PDO('mysql:host=127.0.0.1;port=3306', 'typo3', 'typo3');
  \$stmt = \$pdo->query(\"SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'typo3'\");
  echo \$stmt->rowCount() > 0 ? 'yes' : 'no';
")
assert_equals "TYPO3 database 'typo3' exists" "yes" "$DB_EXISTS"

DB_VERSION=$(php -r "
  \$pdo = new PDO('mysql:host=127.0.0.1;port=3306', 'typo3', 'typo3');
  echo \$pdo->query('SELECT VERSION()')->fetchColumn();
")
assert_contains "MariaDB version is 11.x" "11." "$DB_VERSION"

# --- Webserver Tests ---
echo ""
echo "--- Webserver ---"

assert_success "Web server responds on port 8888" \
  curl -s -o /dev/null -w '' http://127.0.0.1:8888/

# --- Mailpit Tests ---
echo ""
echo "--- Mailpit ---"

assert_success "Mailpit responds on port 8025" \
  curl -s -o /dev/null -w '' http://127.0.0.1:8025/

assert_success "Mailpit SMTP accepts connections on port 1025" \
  php -r "
    \$sock = @fsockopen('127.0.0.1', 1025, \$errno, \$errstr, 5);
    if (!\$sock) exit(1);
    fclose(\$sock);
  "

# --- TYPO3 Tests ---
echo ""
echo "--- TYPO3 Configuration ---"

assert_success "TYPO3 CLI is functional" \
  slh php "$WORKSPACE_PATH/vendor/bin/typo3" list

BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8888/typo3/ || echo "000")
if echo "$BACKEND_STATUS" | grep -qE '(200|303)'; then
  echo -e "${GREEN}PASS${NC}: TYPO3 backend responds (HTTP $BACKEND_STATUS)"
  PASS=$((PASS + 1))
else
  echo -e "${RED}FAIL${NC}: TYPO3 backend responds (expected 200 or 303, got $BACKEND_STATUS)"
  FAIL=$((FAIL + 1))
fi

# --- File Structure Tests ---
echo ""
echo "--- File Structure ---"

assert_success "composer.json exists" test -f "$WORKSPACE_PATH/composer.json"
assert_success "vendor directory exists" test -d "$WORKSPACE_PATH/vendor"
assert_success "public directory exists" test -d "$WORKSPACE_PATH/public"
assert_success "config/system/additional.php exists" test -f "$WORKSPACE_PATH/config/system/additional.php"

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ $FAIL -gt 0 ]; then
  exit 1
fi
