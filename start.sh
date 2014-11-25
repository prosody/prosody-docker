#! /bin/bash

if [ ! "${LOCAL}" ] || [ ! "${PASSWORD}" ] || [ ! "${DOMAIN}" ] ; then
    LOCAL="admin"
    PASSWORD="password"
    DOMAIN="localhost"
fi

prosodyctl register $LOCAL $DOMAIN $PASSWORD || true

prosodyctl start
