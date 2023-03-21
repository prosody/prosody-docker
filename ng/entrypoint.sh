#!/bin/bash -e
set -e

data_dir_owner="$(stat -c %u "/var/lib/prosody/")"
if [[ "$(id -u prosody)" != "$data_dir_owner" ]]; then
    # FIXME this fails if owned by root
    usermod -u "$data_dir_owner" prosody
fi
if [[ "$(stat -c %u /var/run/prosody/)" != "$data_dir_owner" ]]; then
    chown "$data_dir_owner" /var/run/prosody/
fi

if [[ "$1" != "prosody" ]]; then
    exec prosodyctl "$@"
    exit 0;
fi

if [[ "$LOCAL" && "$PASSWORD" && "$DOMAIN" ]]; then
    prosodyctl register "$LOCAL" "$DOMAIN" "$PASSWORD"
fi

exec runuser -u prosody -- "$@"
