#!/usr/bin/env bash


TEST_DIR=$(dirname $0)

export PGINIT_CONFIG="
user0 db0
user1 db1 db2
"

# Wait for postgres to start here since
# it will mess up the diff.
local counter
counter=0
until pg_isready -q; do
  echo "waiting for postgres"
  if [[ "$counter" -gt 60 ]]; then
    echo "timed out waiting for postgres to start"
    exit 1
  else
    counter=$((counter+1))
  fi
done

function pginit {
  docker run \
    --net=host \
    -e "PGHOST=$PGHOST" \
    -e "PGUSER=$PGUSER" \
    -e "PGPASSWORD=$PGPASSWORD" \
    -e "PGINIT_CONFIG=$PGINIT_CONFIG" \
    --rm \
    pginit
}

set -e

echo "First run:\n"

pginit | diff "$TEST_DIR/expected0" -

echo "Second run:\n"
pginit | diff "$TEST_DIR/expected1" -
