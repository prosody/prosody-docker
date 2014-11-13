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
  libssl0.9.8 lua-dbi-sqlite3 lua-sec lua-zlib liblua5.1-expat0

COPY ./prosody.deb /data/prosody.deb

RUN dpkg -i /data/prosody.deb

EXPOSE 443 80 5222 5269 5347 5280 

CMD prosodyctl start