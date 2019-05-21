#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

POSTGRES_CONN_AUTH_FILE="/var/lib/postgresql/data/pg_hba.conf"

# disable all trust authentication, force encrypted password transfer.
sed -i "${POSTGRES_CONN_AUTH_FILE}" -e 's/trust/md5/g'
