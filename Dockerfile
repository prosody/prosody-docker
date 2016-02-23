################################################################################
# Build a dockerfile for Prosody XMPP server
# Based on ubuntu
################################################################################

FROM debian:jessie

MAINTAINER Prosody developers <docker@prosody.im>

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libidn11-dev \
        libssl-dev \
        lua5.2 \
        liblua5.2-dev \
        libidn11 \
        libssl1.0.0 \
        liblua5.2 \
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
        lua5.2 \
        openssl \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install and configure prosody
COPY ./prosody.tar.gz /tmp/prosody.tar.gz
RUN mkdir prosody-build && cd prosody-build && tar xzf /tmp/prosody.tar.gz && cd * && \
    ./configure --ostype=debian --runwith=lua5.2 --lua-suffix=5.2 --with-lua-include=/usr/include/lua5.2 --prefix=/usr && \
    make && \
    make install

RUN apt-get purge -y build-essential libssl-dev libidn11-dev liblua5.2-dev && apt-get autoremove -y && apt-get clean -y

RUN sed -i '1s/^/daemonize = false;\n/' /etc/prosody/prosody.cfg.lua \
    && perl -i -pe 'BEGIN{undef $/;} s/^log = {.*?^}$/log = {\n    {levels = {min = "info"}, to = "console"};\n}/smg' /etc/prosody/prosody.cfg.lua

RUN adduser --disabled-password --quiet --system \
    --home /var/lib/prosody --no-create-home \
    --gecos "Prosody XMPP Server" --group prosody && \
    mkdir -p /var/run/prosody && chown prosody:adm /var/run/prosody && \
    mkdir -p /var/log/prosody && chown prosody:adm /var/log/prosody

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80 443 5222 5269 5347 5280 5281
USER prosody
ENV __FLUSH_LOG yes
CMD ["prosody"]
