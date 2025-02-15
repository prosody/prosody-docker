# Docker build scripts for Prosody build server

This is the Prosody Docker image building repository. It is used by our build server to build and publish Docker images for stable releases and nightly builds.

There are many alternative Dockerfiles for Prosody available if this one
does not suit your needs:

  - [OpusVL/prosody-docker](https://github.com/OpusVL/prosody-docker/)
  - [unclev/prosody-docker-extended](https://github.com/unclev/prosody-docker-extended)

## Published images

For images please see here: [Prosody on Docker](https://hub.docker.com/r/prosody/prosody/).

## Running

It works by enabling the [prosody package repository](https://prosody.im/download/package_repository) and installing the selected Prosody package from there based on the `PROSODY_PACKAGE` build argument.

Docker images are built off an __Debian 12 (bookworm)__ base.

```bash
docker run -d --name prosody -p 5222:5222 prosody/prosody
```

A user can be created by using environment variables `LOCAL`, `DOMAIN`, and `PASSWORD`. This performs the following action on startup:

  prosodyctl register *local* *domain* *password*

Any error from this script is ignored. Prosody will not check the user exists before running the command (i.e. existing users will be overwritten). It is expected that [mod_admin_adhoc](http://prosody.im/doc/modules/mod_admin_adhoc) will then be in place for managing users (and the server).

### Ports

The image exposes the following ports to the docker host:

* __80__: HTTP port
* __443__: HTTPS port
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
* __/etc/prosody/certs__:
  * SSL certificates
* __/etc/prosody/modules__:
  * Location for including additional modules

### Environment Variables

* `DOMAIN`, `LOCAL`, `PASSWORD` - These three are used by `entrypoint.sh` to create an initial account `$LOCAL@$DOMAIN` with `$PASSWORD` as password.
* `PROSODY_PLUGIN_PATHS` - Comma-separated list of additional paths to search for plugins. Defaults to `/etc/prosody/modules`.
* `PROSODY_ADMINS` - Comma-separated list of user addresses treated as admins.
* `PROSODY_ENABLE_MODULES` - Comma-separated list of additional plugins to load.
* `PROSODY_DISABLE_MODULES` - Comma-separated list of modules to disable, e.g. for auto-enabled modules.
* `PROSODY_TURN_HOST` - Hostname of TURN server
* `PROSODY_TURN_PORT` - Port number of TURN server
* `PROSODY_TURN_SECRET` - Shared secret for TURN
* `PROSODY_TURN_TLS_PORT` -  Port number for STUN over TLS
* `PROSODY_RETENTION_DAYS` - How many days worth of message archives and shared file to keep.
* `PROSODY_S2S_SECURE_AUTH` - Whether to require that remote servers present valid certificates. Enabled by default.
* `PROSODY_C2S_RATE_LIMIT` - Rate limit for client-to-server connections. Defaults to `10kb/s`.
* `PROSODY_S2S_RATE_LIMIT` - Rate limit for server-to-server connections. Defaults to `30kb/s`.
* `PROSODY_STORAGE` - [Storage driver](https://prosody.im/doc/storage) to use. Defaults to `internal`.
* `PROSODY_SQL_DRIVER` - One of `SQLite3`, `PostgreSQL` or `MySQL`. Selects SQL backend when `PROSODY_STORAGE` is set to `sql`.
* `PROSODY_SQL_DB` - Name of SQL database to use.
* `PROSODY_SQL_HOST` - Hostname of SQL database to connect to (PostgreSQL and MySQL only).
* `PROSODY_SQL_USERNAME`, `PROSODY_SQL_PASSWORD` - Credentials for connecting to SQL database.
* `PROSODY_ARCHIVE_EXPIRY_DAYS` - When set, overrides `PROSODY_RETENTION_DAYS` for message archives.
* `PROSODY_LOGLEVEL` - Log level, one of `debug`, `info`, `warn`, `error`. Defaults to `info`.
* `PROSODY_STATISTICS` - [Statistics provider](https://prosody.im/doc/statistics) to use, e.g. `internal`. Default disabled.
* `PROSODY_STATISTICS_INTERVAL` - Statistics collection interval. A number or the string `manual` for OpenMetrics-triggered collection. Defaults to `60`.
* `PROSODY_CERTIFICATES` - Path to TLS certificates and private keys, relative to the config file. Defaults to `certs`, i.e.
* `PROSODY_VIRTUAL_HOSTS` - Comma-separated list of domain names to initialize as hosts that provide user accounts. Defaults to the hostname of the container. `/etc/prosody/certs`.
* `PROSODY_NETWORK_HOSTNAME` - Public domain name for use with e.g. HTTP. Defaults to the first entry in `PROSODY_VIRTUAL_HOSTS`.
* `PROSODY_COMPONENTS` - Comma-separated list of _internal_ components in the form `name.example.com:type` where `type` can be e.g. `muc`, `http_file_share`.
* `PROSODY_MUC_MODULES` - Comma-separated list of additional modules to enable on a MUC component.
* `PROSODY_UPLOAD_EXPIRY_DAYS` - When set, overrides `PROSODY_RETENTION_DAYS` for uploaded files.
* `PROSODY_UPLOAD_LIMIT_MB` - Size limit in MiB for individual uploaded files.
* `PROSODY_UPLOAD_STORAGE_GB` - Total amount of storage available for file uploads.
* `PROSODY_EXTERNAL_COMPONENTS` - Comma-separated list of _external_ components, in the form of `name.example.com:secret`.
* `PROSODY_COMPONENT_SECRET` - Component shared secret if not provided as part of `PROSODY_EXTERNAL_COMPONENTS`.
* `PROSODY_EXTRA_CONFIG` - Path to additional configuration file. Can contain wildcards. Defaults to `/etc/prosody/conf.d/*.cfg.lua`.


### Example

```bash
docker run -it \
   -p 5222:5222 \
   -p 5269:5269 \
   -e LOCAL=romeo \
   -e DOMAIN=shakespeare.lit \
   -e PASSWORD=juliet4ever \
   -v /data/prosody/configuration:/etc/prosody \
   -v /logs/prosody:/var/log/prosody \
   -v /data/prosody/modules:/usr/lib/prosody-modules \
   prosody/prosody:0.12
```

## Building

```bash
docker build --build-arg PROSODY_PACKAGE=prosody-0.12 -t prosody/prosody:0.12 .
```
