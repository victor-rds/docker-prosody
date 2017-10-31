#!/bin/bash
set -e

if [[ -z  /etc/prosody/prosody.cfg.lua ]]; then
	cp -r /usr/local/src/prosody/* /etc/prosody/
fi

if [[ "$1" != "prosody" ]]; then
    exec prosodyctl $*
    exit 0;
fi

if [ "$USER" -a  "$PASSWORD" -a "$DOMAIN" ] ; then
    prosodyctl register $USER $DOMAIN $PASSWORD
fi

if find /usr/lib/prosody/prosody-modules -mindepth 1 -print -quit | grep -q .; then
    cd /usr/lib/prosody/prosody-modules
	hg pull --update
	cd -
else
    hg clone https://hg.prosody.im/prosody-modules/ /usr/lib/prosody/prosody-modules
fi

exec "$@"