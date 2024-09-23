#!/usr/bin/env bash

set -e

TEST_DIR=$(dirname $0)

export PGINIT_CONFIG="
user0 db0
user1 db1 db2
"

docker run -e "PGINIT_CONFIG=$PGINIT_CONFIG" --rm pginit | diff "$TEST_DIR/expected0" -
docker run -e "PGINIT_CONFIG=$PGINIT_CONFIG" --rm pginit | diff "$TEST_DIR/expected1" -
