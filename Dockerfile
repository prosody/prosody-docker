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
RUN apt-get install -y mercurial python-setuptools python-dev build-essential libidn11-dev libssl-dev wget bsdmainutils 

CMD useradd -ms /bin/bash prosody && groupadd prosody && useradd -G prosody prosody
RUN echo deb http://packages.prosody.im/debian $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list
RUN wget https://prosody.im/files/prosody-debian-packages.key -O- | apt-key add -
RUN apt-get update
RUN apt-get install -y lua5.2 luajit luarocks lua-event lua-zlib lua-dbi-mysql lua-dbi-postgresql lua-dbi-sqlite3 lua-socket liblua5.1-expat0 liblua5.1-filesystem0 lua-sec

RUN hg clone http://hg.prosody.im/trunk prosody
RUN cd prosody &&  ./configure --ostype=debian && make && make install

EXPOSE 443 80 5222 5269 5347 5280 

CMD prosodyctl start
