################################################################################
# Build a dockerfile for Prosody XMPP server
# Based on Debian Stretch
################################################################################

FROM debian:stretch

MAINTAINER Lloyd Watkin <lloyd@evilprofessor.co.uk>

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libidn11 \
        libssl1.0.2 \
        lua-bitop \
        lua-dbi-mysql \
        lua-dbi-postgresql \
        lua-dbi-sqlite3 \
        lua-event \
        lua-expat \
        lua-filesystem \
        lua-sec \
        lua-socket \
        lua-zlib \
        lua5.1 \
        openssl \
	ssl-cert \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install and configure prosody
COPY ./prosody.deb /tmp/prosody.deb
RUN dpkg -i /tmp/prosody.deb \
    && sed -i '1s/^/daemonize = false;\n/' /etc/prosody/prosody.cfg.lua \
    && perl -i -pe 'BEGIN{undef $/;} s/^log = {.*?^}$/log = {\n    {levels = {min = "info"}, to = "console"};\n}/smg' /etc/prosody/prosody.cfg.lua

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=5s --timeout=2s --retries=5 \
	CMD bash -c "</dev/tcp/localhost/5222 && </dev/tcp/localhost/5269"

EXPOSE 80 443 5222 5269 5347 5280 5281
USER prosody
ENV __FLUSH_LOG yes
CMD ["prosody"]
