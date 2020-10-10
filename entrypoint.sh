#!/bin/bash
set -e

usermod -u "$(stat -c %u /var/lib/prosody/.)" prosody

if [[ "$1" != "prosody" ]]; then
    exec prosodyctl "$@"
    exit 0;
fi

if [ "$LOCAL" -a  "$PASSWORD" -a "$DOMAIN" ] ; then
    prosodyctl register "$LOCAL" "$DOMAIN" "$PASSWORD"
fi

exec runuser -u prosody -- "$@"
