#!/bin/bash
set -e

: ${PROSODY_USERID:=101}

if [ "$PROSODY_USERID" != "101" ]; then
	usermod -u "$PROSODY_USERID" prosody;
	groupmod -g "$PROSODY_USERID" prosody;
fi

if [[ "$1" != "prosody" ]]; then
    exec prosodyctl "$@"
    exit 0;
fi

if [ "$LOCAL" -a  "$PASSWORD" -a "$DOMAIN" ] ; then
    prosodyctl register "$LOCAL" "$DOMAIN" "$PASSWORD"
fi

exec "$@"
