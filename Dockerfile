################################################################################
# Build a dockerfile for Prosody XMPP server
# Based on ubuntu
################################################################################

FROM alpine:3.3

MAINTAINER Prosody Developers <docker@prosody.im>

# Install dependencies
RUN apk add --update --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ prosody && rm -rf /var/cache/apk/*

# Install and configure prosody
COPY ./prosody.deb /tmp/prosody.deb
RUN sed -i 's/daemonize = true/daemonize = false/;s/\*syslog/*console/' /etc/prosody/prosody.cfg.lua

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80 443 5222 5269 5347 5280 5281
USER prosody
ENV __FLUSH_LOG yes
CMD ["/usr/bin/prosody"]
