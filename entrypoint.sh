#!/bin/sh
set -e

if [ "x$1" != "x/usr/bin/prosody" ]; then
    exec /usr/bin/prosodyctl $*
    exit 0;
fi

if [ "$LOCAL" -a  "$PASSWORD" -a "$DOMAIN" ] ; then
    /usr/bin/prosodyctl register $LOCAL $DOMAIN $PASSWORD
fi

exec "$@"
