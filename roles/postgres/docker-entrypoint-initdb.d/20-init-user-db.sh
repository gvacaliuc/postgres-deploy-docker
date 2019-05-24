#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

USER_FILE="/docker-entrypoint-initdb.d/users"

echo "User Database Initialization Script"
echo "Users to create databases for:"
cat "${USER_FILE}" | cut -d' ' -f1

# may want to change this all to psql commands
function _createuser() {
    local USERNAME="$1"
    local PASSWORD="$2"
    createuser -U "${POSTGRES_USER}" -w \
        -d \
        -l \
        -R \
        -S \
        --replication \
        "${USERNAME}"
    if [[ -n "$PASSWORD" ]]
    then
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOF
            alter user ${USERNAME} with encrypted password '${PASSWORD}';
EOF
    fi
}

# may want to change this all to psql commands
function _copyDB() {
    local USERNAME="$1"
    echo "copying DB(${POSTGRES_DB}) to DB(${USERNAME}) for ${USERNAME}"
    createdb -U "${POSTGRES_USER}" -w \
        -O "${USERNAME}" \
        -T "${POSTGRES_DB}" \
        "${USERNAME}"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "${USERNAME}" <<-EOF
        GRANT ALL PRIVILEGES ON DATABASE ${USERNAME} TO ${USERNAME};
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${USERNAME};
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${USERNAME};
EOF
}

for user_and_pass in $(cat "${USER_FILE}"); do
    # admittedly, this is a hacky way to get the username and password
    OLD="$IFS"
    IFS=$' '
    array=($user_and_pass)
    IFS=${OLD}
    user=${array[0]}
    password=${array[1]}
    _createuser "$user" "$password"
    _copyDB "$user"
done
