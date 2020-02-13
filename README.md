# Docker build scripts for Prosody build server

This is the Prosody Docker image building repository. It is used by our build server to build and publish Docker images for stable releases and nightly builds.

**Note:** Using this Dockerfile outside of our build server is not a supported use-case. There are many
alternative Dockerfiles for Prosody available which can be used for this:

  - [OpusVL/prosody-docker](https://github.com/OpusVL/prosody-docker/)
  - [unclev/prosody-docker-extended](https://github.com/unclev/prosody-docker-extended)

## Published images

For images please see here: [Prosody on Docker](https://hub.docker.com/r/prosody/prosody/).

## Running

It works by copying in a recently built `deb` file and running the install on the system.

Docker images are built off an __Debian 10 (buster)__ base.

```bash
docker run -d --name prosody -p 5222:5222 prosody/prosody
```

A user can be created by using environment variables `LOCAL`, `DOMAIN`, and `PASSWORD`. This performs the following action on startup:

  prosodyctl register *local* *domain* *password*

Any error from this script is ignored. Prosody will not check the user exists before running the command (i.e. existing users will be overwritten). It is expected that [mod_admin_adhoc](http://prosody.im/doc/modules/mod_admin_adhoc) will then be in place for managing users (and the server).

### Ports

The image exposes the following ports to the docker host:

* __80__: HTTP port
* __5222__: c2s port
* __5269__: s2s port
* __5347__: XMPP component port
* __5280__: BOSH / websocket port
* __5281__: Secure BOSH / websocket port

Note: These default ports can be changed in your configuration file. Therefore if you change these ports will not be exposed.

### Volumes

Volumes can be mounted at the following locations for adding in files:

* __/etc/prosody__:
  * Prosody configuration file(s)
  * SSL certificates
* __/var/log/prosody__:
  * Log files for prosody - if not mounted these will be stored on the system
  * Note: This location can be changed in the configuration, update to match
  * Also note: The log directory on the host (/logs/prosody in the example below) must be writeable by the prosody user
* __/usr/lib/prosody-modules__ (suggested):
  * Location for including additional modules
  * Note: This needs to be included in your config file, see http://prosody.im/doc/installing_modules#paths

### Example

```
docker run -d \
   -p 5222:5222 \
   -p 5269:5269 \
   -p localhost:5347:5347 \
   -e LOCAL=romeo \
   -e DOMAIN=shakespeare.lit \
   -e PASSWORD=juliet4ever \
   -v /data/prosody/configuration:/etc/prosody \
   -v /logs/prosody:/var/log/prosody \
   -v /data/prosody/modules:/usr/lib/prosody-modules \
   prosody/prosody:0.9
```

## Building

Use the `build-docker.sh` script as follows:

```bash
./build-docker.sh /path/to/built-image.deb version_tag [, ...version_tag2, ...]
```

Where argument 1 is a pointer to the build `deb` file that you'd like to make an image from and 'version_tag' is the tag you'd like to push to the Docker registry with.

You can specify multiple tags by adding additional tag names to the end of the command. This is useful where a for example release 0.10.4 is made which also consitutes 'latest', '0.10-nightly', '0.10.4', '0.10' images.

After running the script will clean up any images generated (but not the base images - for efficiency purposes).
