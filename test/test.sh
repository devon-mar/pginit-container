#!/usr/bin/env bash

set -e

TEST_DIR=$(dirname $0)

export PGINIT_CONFIG="
user0 db0
user1 db1 db2
"

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

echo "First run:\n"

pginit | diff "$TEST_DIR/expected0" -

echo "Second run:\n"
pginit | diff "$TEST_DIR/expected1" -
