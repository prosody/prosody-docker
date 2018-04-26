################################################################################
# Build a dockerfile for Prosody XMPP server
# Based on ubuntu
################################################################################

FROM ubuntu:16.04

MAINTAINER Lloyd Watkin <lloyd@evilprofessor.co.uk>

# Install prerequest
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget \
    lsb-base \
    adduser \
    libidn11 \
    libssl1.0.0 \
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
    ca-certificates \
    ssl-cert \
    lua-sec

# Install prosody
RUN echo deb http://packages.prosody.im/debian xenial main | tee -a /etc/apt/sources.list \
    && wget --no-check-certificate https://prosody.im/files/prosody-debian-packages.key -O- | apt-key add - \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends  \
    prosody \
    && rm -rf /var/lib/apt/lists/*

# Configure prosody
RUN sed -i '1s/^/daemonize = false;\n/' /etc/prosody/prosody.cfg.lua \
    && perl -i -pe 'BEGIN{undef $/;} s/^log = {.*?^}$/log = {\n    {levels = {min = "info"}, to = "console"};\n}/smg' /etc/prosody/prosody.cfg.lua

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh && mkdir -p /var/run/prosody && chown prosody:prosody /var/run/prosody
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80 443 5222 5269 5347 5280 5281
USER prosody
ENV __FLUSH_LOG yes
CMD ["prosody"]
