#!/bin/bash
set -euo pipefail

# Example:
# API_URL=http://kiosk.local PIN=1111 ./mysql_examples.sh
# API_URL=http://192.168.0.103 PIN=1234 ./mysql_examples.sh

API_URL="${API_URL:-${1:-http://kiosk.local}}"
PIN="${PIN:-${2:-1111}}"

DEMO_DB="${DEMO_DB:-api_demo}"
DEMO_TABLE="${DEMO_TABLE:-products}"

DEMO_USER="${DEMO_USER:-api_demo_user}"
DEMO_USER_HOST="${DEMO_USER_HOST:-localhost}"
DEMO_USER_PASSWORD="${DEMO_USER_PASSWORD:-DemoPassword123!}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

log_step() {
  echo
  echo "== $1 =="
}

api_json() {
  local method="$1"
  local endpoint="$2"
  local data="${3:-}"

  if [[ -n "$data" ]]; then
    curl -sS -X "$method" "$API_URL$endpoint" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "$data"
  else
    curl -sS -X "$method" "$API_URL$endpoint" \
      -H "Authorization: Bearer $TOKEN"
  fi
}

api_get() {
  local endpoint="$1"

  curl -sS "$API_URL$endpoint" \
    -H "Authorization: Bearer $TOKEN"
}

require_cmd curl
require_cmd jq

# ------------------------------------------------------------
# LOGIN
# ------------------------------------------------------------

log_step "Login"

LOGIN_RESPONSE=$(curl -sS -X POST "$API_URL/api/login" \
  -H "Content-Type: application/json" \
  -d "{\"pin\":\"$PIN\"}")
echo "$LOGIN_RESPONSE"
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token')

if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
  echo "Login failed"
  echo "$LOGIN_RESPONSE"
  exit 1
fi

echo "Token acquired"

# ------------------------------------------------------------
# MYSQL STATUS
# ------------------------------------------------------------

log_step "MariaDB/MySQL status: /api/mysql/status GET"

api_get "/api/mysql/status" | jq .

# ------------------------------------------------------------
# DATABASES
# ------------------------------------------------------------

log_step "List databases: /api/mysql/databases GET"

api_get "/api/mysql/databases" | jq .

# ------------------------------------------------------------
# CREATE DATABASE
# ------------------------------------------------------------

log_step "Create database: /api/mysql/database POST"

api_json POST "/api/mysql/database" \
  "{\"database\":\"$DEMO_DB\"}" | jq .

# ------------------------------------------------------------
# LIST DATABASES AGAIN
# ------------------------------------------------------------

log_step "List databases after creation"

api_get "/api/mysql/databases" | jq .

# ------------------------------------------------------------
# CREATE TABLE
# ------------------------------------------------------------

log_step "Create table: /api/mysql/table POST"

TABLE_JSON=$(cat <<EOF
{
  "database": "$DEMO_DB",
  "table": "$DEMO_TABLE",
  "columns": [
    {
      "name": "id",
      "type": "INT",
      "nullable": false,
      "primary": true,
      "auto_increment": true
    },
    {
      "name": "name",
      "type": "VARCHAR(255)",
      "nullable": false
    },
    {
      "name": "price",
      "type": "DECIMAL(10,2)",
      "nullable": false,
      "default": 0
    },
    {
      "name": "active",
      "type": "BOOLEAN",
      "nullable": false,
      "default": 1
    }
  ]
}
EOF
)

api_json POST "/api/mysql/table" "$TABLE_JSON" | jq .

# ------------------------------------------------------------
# LIST TABLES
# ------------------------------------------------------------

log_step "List tables: /api/mysql/tables GET"

api_get "/api/mysql/tables?database=$DEMO_DB" | jq .

# ------------------------------------------------------------
# TABLE STRUCTURE
# ------------------------------------------------------------

log_step "Table structure: /api/mysql/table/structure GET"

api_get "/api/mysql/table/structure?database=$DEMO_DB&table=$DEMO_TABLE" | jq .

# ------------------------------------------------------------
# INSERT
# ------------------------------------------------------------

log_step "Insert record #1: /api/mysql/data POST"

api_json POST "/api/mysql/data" \
  "{
    \"database\":\"$DEMO_DB\",
    \"table\":\"$DEMO_TABLE\",
    \"data\":{
      \"name\":\"Kawa\",
      \"price\":12.50,
      \"active\":true
    }
  }" | jq .

log_step "Insert record #2: /api/mysql/data POST"

api_json POST "/api/mysql/data" \
  "{
    \"database\":\"$DEMO_DB\",
    \"table\":\"$DEMO_TABLE\",
    \"data\":{
      \"name\":\"Herbata\",
      \"price\":10.00,
      \"active\":true
    }
  }" | jq .

log_step "Insert record #3: /api/mysql/data POST"

api_json POST "/api/mysql/data" \
  "{
    \"database\":\"$DEMO_DB\",
    \"table\":\"$DEMO_TABLE\",
    \"data\":{
      \"name\":\"Ciastko\",
      \"price\":8.50,
      \"active\":false
    }
  }" | jq .

# ------------------------------------------------------------
# SELECT
# ------------------------------------------------------------

log_step "Select all records: /api/mysql/data GET"

api_get "/api/mysql/data?database=$DEMO_DB&table=$DEMO_TABLE" | jq .

# ------------------------------------------------------------
# SELECT WITH PAGINATION
# ------------------------------------------------------------

log_step "Select with pagination"

api_get "/api/mysql/data?database=$DEMO_DB&table=$DEMO_TABLE&page=1&per_page=2" | jq .

# ------------------------------------------------------------
# SELECT WITH FILTER
# ------------------------------------------------------------

log_step "Select with filter: active=1"

curl -sS -G "$API_URL/api/mysql/data" \
  -H "Authorization: Bearer $TOKEN" \
  --data-urlencode "database=$DEMO_DB" \
  --data-urlencode "table=$DEMO_TABLE" \
  --data-urlencode "where[active]=1" | jq .

# ------------------------------------------------------------
# SELECT SORTED
# ------------------------------------------------------------

log_step "Select sorted by price"

api_get "/api/mysql/data?database=$DEMO_DB&table=$DEMO_TABLE&sort=price&order=desc" | jq .

# ------------------------------------------------------------
# UPDATE
# ------------------------------------------------------------

log_step "Update record: /api/mysql/data PUT"

api_json PUT "/api/mysql/data" \
  "{
    \"database\":\"$DEMO_DB\",
    \"table\":\"$DEMO_TABLE\",
    \"data\":{
      \"price\":13.50
    },
    \"where\":{
      \"name\":\"Kawa\"
    }
  }" | jq .

# ------------------------------------------------------------
# VERIFY UPDATE
# ------------------------------------------------------------

log_step "Verify updated record"

curl -sS -G "$API_URL/api/mysql/data" \
  -H "Authorization: Bearer $TOKEN" \
  --data-urlencode "database=$DEMO_DB" \
  --data-urlencode "table=$DEMO_TABLE" \
  --data-urlencode "where[name]=Kawa" | jq .

# ------------------------------------------------------------
# DELETE ONE RECORD
# ------------------------------------------------------------

log_step "Delete record: /api/mysql/data DELETE"

api_json DELETE "/api/mysql/data" \
  "{
    \"database\":\"$DEMO_DB\",
    \"table\":\"$DEMO_TABLE\",
    \"where\":{
      \"name\":\"Ciastko\"
    }
  }" | jq .

# ------------------------------------------------------------
# VERIFY DELETE
# ------------------------------------------------------------

log_step "Verify deleted record"

api_get "/api/mysql/data?database=$DEMO_DB&table=$DEMO_TABLE" | jq .

# ------------------------------------------------------------
# USERS
# ------------------------------------------------------------

log_step "List MySQL users: /api/mysql/users GET"

api_get "/api/mysql/users" | jq .

# ------------------------------------------------------------
# CREATE USER
# ------------------------------------------------------------

log_step "Create MySQL user: /api/mysql/user POST"

api_json POST "/api/mysql/user" \
  "{
    \"username\":\"$DEMO_USER\",
    \"host\":\"$DEMO_USER_HOST\",
    \"password\":\"$DEMO_USER_PASSWORD\"
  }" | jq .

# ------------------------------------------------------------
# LIST USERS AGAIN
# ------------------------------------------------------------

log_step "List MySQL users after creation"

api_get "/api/mysql/users" | jq .

# ------------------------------------------------------------
# GRANT
# ------------------------------------------------------------

log_step "Grant permissions: /api/mysql/user/grants POST"

api_json POST "/api/mysql/user/grants" \
  "{
    \"username\":\"$DEMO_USER\",
    \"host\":\"$DEMO_USER_HOST\",
    \"database\":\"$DEMO_DB\",
    \"table\":\"*\",
    \"privileges\":[
      \"SELECT\",
      \"INSERT\",
      \"UPDATE\",
      \"DELETE\"
    ]
  }" | jq .

# ------------------------------------------------------------
# SHOW GRANTS
# ------------------------------------------------------------

log_step "Show user grants: /api/mysql/user/grants GET"

curl -sS -G "$API_URL/api/mysql/user/grants" \
  -H "Authorization: Bearer $TOKEN" \
  --data-urlencode "username=$DEMO_USER" \
  --data-urlencode "host=$DEMO_USER_HOST" | jq .

# ------------------------------------------------------------
# REVOKE
# ------------------------------------------------------------

log_step "Revoke UPDATE permission"

api_json POST "/api/mysql/user/revoke" \
  "{
    \"username\":\"$DEMO_USER\",
    \"host\":\"$DEMO_USER_HOST\",
    \"database\":\"$DEMO_DB\",
    \"table\":\"*\",
    \"privileges\":[
      \"UPDATE\"
    ]
  }" | jq .

# ------------------------------------------------------------
# SHOW GRANTS AFTER REVOKE
# ------------------------------------------------------------

log_step "Show grants after REVOKE"

curl -sS -G "$API_URL/api/mysql/user/grants" \
  -H "Authorization: Bearer $TOKEN" \
  --data-urlencode "username=$DEMO_USER" \
  --data-urlencode "host=$DEMO_USER_HOST" | jq .

# ------------------------------------------------------------
# DELETE USER
# ------------------------------------------------------------

log_step "Delete MySQL user: /api/mysql/user DELETE"

api_json DELETE "/api/mysql/user" \
  "{
    \"username\":\"$DEMO_USER\",
    \"host\":\"$DEMO_USER_HOST\"
  }" | jq .

# ------------------------------------------------------------
# DELETE TABLE
# ------------------------------------------------------------

log_step "Delete table: /api/mysql/table DELETE"

api_json DELETE "/api/mysql/table" \
  "{
    \"database\":\"$DEMO_DB\",
    \"table\":\"$DEMO_TABLE\",
    \"confirm\":\"$DEMO_TABLE\"
  }" | jq .

# ------------------------------------------------------------
# DELETE DATABASE
# ------------------------------------------------------------

log_step "Delete database: /api/mysql/database DELETE"

api_json DELETE "/api/mysql/database" \
  "{
    \"database\":\"$DEMO_DB\",
    \"confirm\":\"$DEMO_DB\"
  }" | jq .

# ------------------------------------------------------------
# FINAL STATUS
# ------------------------------------------------------------

log_step "Final database list"

api_get "/api/mysql/databases" | jq .

echo
echo "All MySQL/MariaDB API examples completed."
