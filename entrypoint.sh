#!/usr/bin/env bash

# $1: database name
# $2: database user
function create_database {
  local dbname=$1
  local dbuser=$2

  # https://stackoverflow.com/questions/14549270/check-if-database-exists-in-postgresql-using-shell
  if [ "$( psql -XtAc "SELECT 1 FROM pg_database WHERE datname='$dbname'" )" = '1' ]; then
    echo "  Database $dbname exists."
  else
    echo "  Creating database $dbname with owner $dbuser."
    if ! createdb --owner "$dbuser" "$dbname"; then
      echo "  Failed to create database $dbname."
      exit 1
    fi
  fi
}

# $1: username
function create_user {
  local user=$1
  if [ "$( psql -XtAc "SELECT 1 FROM pg_roles WHERE rolname='$user'" )" = '1' ]; then
    echo "  User $user exists."
  else
    echo "  Creating user $user."
    if ! createuser "$user"; then
      echo "  Failed to create user $user."
      exit 1
    fi
  fi
}

function main {
  if [[ -z "$PGINIT_CONFIG" ]]; then
    echo "PGINIT_CONFIG is not set."
    exit 1
  fi

  local counter
  counter=0
  until pg_isready -q; do
    echo "waiting for postgres $PGHOST:$PGPORT"
    if [[ "$counter" -gt 60 ]]; then
      echo "timed out waiting for postgres to start"
      exit 1
    else
      counter=$((counter+1))
    fi
  done

  while read -r line; do
    if [[ -n "$line" ]]; then
      echo "Processing line: $line"

      read -r -a params <<< "$line"

      if [[ "${#params[@]}" -lt 2 ]]; then
        echo "  line is missing parameters"
        exit 1
      fi

      user="${params[0]}"

      create_user "$user"

      for dbname in "${params[@]:1}"; do
        create_database "$dbname" "$user"
      done
    fi
  done <<< "$PGINIT_CONFIG"
}

main
