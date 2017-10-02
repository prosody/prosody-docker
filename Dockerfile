################################################################################
# Build a dockerfile for Prosody XMPP server
# Based on Debian Stretch
################################################################################

FROM debian:stretch

LABEL maintainer="m@maltris.org"

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
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
    && apt-get autoremove -y --purge && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install prosody
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
        	curl \
        	software-properties-common \
		gnupg2 \
	&& echo "deb http://packages.prosody.im/debian stretch main" > /etc/apt/sources.list.d/prosody.list \
        && curl https://prosody.im/files/prosody-debian-packages.key | apt-key add - && apt-get update \
	&& apt-get install -y --no-install-recommends \
		prosody \
        && apt-get purge -y \
		curl \
		software-properties-common \
		gnupg2 \
	&& apt-get autoremove -y --purge && apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/prosody.list

# Configure prosody
RUN sed -i '1s/^/daemonize = false;\n/' /etc/prosody/prosody.cfg.lua \
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
