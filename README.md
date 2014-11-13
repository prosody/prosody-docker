# Prosody Docker

This is the Prosody Docker image building repository. Its only really designed to be used on the Prosody build server for pushing to the [Docker registry](https://registry.hub.docker.com/repos/prosody/).

It works by coping in a recently built `deb` file and running the install on the system.

Docker images are built off an __Ubuntu 14.04 LTS__ base.

```bash
docker run -d prosody/prosody --name prosody -p 5222:5222
```

## Ports

The image exposes the following ports to the docker host:

* __80__: HTTP port
* __5222__: c2s port
* __5269__: s2s port
* __5347__: XMPP component port
* __5280__: BOSH / websocket port

Note: These default ports can be changed in your configuration file. Therefore if you change these ports will not be exposed.

## Volumes

Volumes can be mounted at the following locations for adding in files:

* __/etc/prosody__:
  * Prosody configuration file(s)
  * SSL certificates
* __/var/log/prosody__:
  * Log files for prosody - if not mounted these will be stored on the system
  * Note: This location can be changed in the configuration, update to match
* __/usr/lib/prosody-modules__ (suggested):
  * Location for including additional modules
  * Note: This needs to be included in your config file, see http://prosody.im/doc/installing_modules#paths

## Example

```
docker run -d prosody/prosody:0.9 \
   -p 5222:5222 \
   -p 5269:5269 \
   -p localhost:5347:5347 \
   -v /etc/prosody /data/prosody/configuration \
   -v /var/log/prosody /logs/prosody \
   -v /usr/lib/prosody-modules /data/prosody/modules
```