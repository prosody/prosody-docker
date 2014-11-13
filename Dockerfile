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

COPY ./build-file.deb /data/prosody.deb

RUN dpkg -i /data/prosody.deb

RUN apt-get update
RUN apt-get install -y lua-event lua-zlib lua-dbi-mysql lua-dbi-postgresql lua-dbi-sqlite3

EXPOSE 443 80 5222 5269 5347 5280 

CMD prosodyctl start