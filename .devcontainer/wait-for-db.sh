#!/usr/bin/zsh

set -e

MAX_RETRIES=30
RETRY_INTERVAL=2
HOST=127.0.0.1
PORT=3306

echo "Waiting for MariaDB to be ready on ${HOST}:${PORT}..."

for i in $(seq 1 $MAX_RETRIES); do
  if php -r "try { new PDO('mysql:host=${HOST};port=${PORT}', 'typo3', 'typo3'); echo 'ok'; exit(0); } catch (Exception \$e) { exit(1); }" 2>/dev/null; then
    echo "MariaDB is ready after ${i} attempts."
    exit 0
  fi
  echo "Attempt ${i}/${MAX_RETRIES}: MariaDB not ready yet, retrying in ${RETRY_INTERVAL}s..."
  sleep $RETRY_INTERVAL
done

echo "ERROR: MariaDB did not become ready after ${MAX_RETRIES} attempts."
exit 1
