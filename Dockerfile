################################################################################
# Build a dockerfile for Prosody XMPP server
# Based on ubuntu
################################################################################

FROM ubuntu:14.04

MAINTAINER Lloyd Watkin <lloyd@evilprofessor.co.uk>

RUN mkdir /data
WORKDIR /data

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y openssl lua5.1 lua-expat lua-socket lua-filesystem \
  libidn11 lua-event lua-zlib lua-dbi-mysql lua-dbi-postgresql \
  lua-dbi-sqlite3 libssl1.0.0 lua-sec lua-zlib liblua5.1-expat0

COPY ./prosody.deb /data/prosody.deb

RUN dpkg -i /data/prosody.deb

# If using default configuration keep a process alive
RUN echo 'daemonize = false;' | cat - /etc/prosody/prosody.cfg.lua > temp && mv temp /etc/prosody/prosody.cfg.lua

EXPOSE 443 80 5222 5269 5347 5280 

ENTRYPOINT prosodyctl start