################################################################################
# Build a dockerfile for Prosody XMPP server
# Based on ubuntu
################################################################################

FROM fedora:latest

MAINTAINER Prosody Developers <docker@prosody.im>

# Install dependencies
RUN dnf -y update && dnf -y clean all
RUN dnf -y install prosody && dnf -y clean all

RUN sed -i -e 's/--daemonize = .*$/daemonize = false/;/^log = {/,/^}/ { /^  /d; /^}/i\' -e '  debug = "*console"' -e '; p ;d };' /etc/prosody/prosody.cfg.lua

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80 443 5222 5269 5347 5280 5281
USER prosody
ENV __FLUSH_LOG yes
CMD ["/usr/bin/prosody"]
