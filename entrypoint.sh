#!/bin/bash
set -e

if [[ "$1" != "prosody" ]]; then
    exec prosodyctl $*
    exit 0;
fi

if [ "$LOCAL" -a  "$PASSWORD" -a "$DOMAIN" ] ; then
    prosodyctl register $LOCAL $DOMAIN $PASSWORD
fi

exec "$@"
