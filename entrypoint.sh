#!/bin/bash
set -e

CHOWN=${CHOWN:-\
/etc/prosody \
/var/lib/prosody \
/var/run/prosody \
/var/log/prosody \
/usr/lib/prosody-modules \
}

if (( EUID == 0 )); then
	for DIR in $CHOWN
	do
		find $DIR \! -user prosody -exec chown prosody '{}' +
	done

    setpriv --reuid=prosody --regid=prosody --init-groups "$BASH_SOURCE" "$@"
fi

if [[ "$1" != "prosody" ]]; then
    exec prosodyctl "$@"
    exit 0;
fi

if [ "$LOCAL" -a  "$PASSWORD" -a "$DOMAIN" ] ; then
    prosodyctl register "$LOCAL" "$DOMAIN" "$PASSWORD"
fi

exec "$@"
