-- Prosody Configuration File
--
-- Information on configuring Prosody can be found on our
-- website at https://prosody.im/doc/configure
--
-- Tip: You can check that the syntax of this file is correct
-- when you have finished by running this command:
--     prosodyctl check config
-- If there are any errors, it will let you know what and where
-- they are, otherwise it will keep quiet.
--
-- The only thing left to do is rename this file to remove the .dist ending, and fill in the
-- blanks. Good luck, and happy Jabbering!

local function _split(s, sep)
	if not s then return nil; end
	sep = sep or ",";
	local parts = {};
	for part in s:gmatch("[^"..sep.."]+") do
		parts[#parts+1] = part;
	end
	return parts;
end


---------- Server-wide settings ----------
-- Settings in this section apply to the whole server and are the default settings
-- for any virtual hosts

plugin_paths = _split(ENV_PROSODY_PLUGIN_PATHS or "/etc/prosody/modules")

-- This is a (by default, empty) list of accounts that are admins
-- for the server. Note that you must create the accounts separately
-- (see https://prosody.im/doc/creating_accounts for info)
-- Example: admins = { "user1@example.com", "user2@example.net" }
admins = _split(ENV_PROSODY_ADMINS)

-- This option allows you to specify additional locations where Prosody
-- will search first for modules. For additional modules you can install, see
-- the community module repository at https://modules.prosody.im/
--plugin_paths = {}

-- This is the list of modules Prosody will load on startup.
-- Documentation for bundled modules can be found at: https://prosody.im/doc/modules
local default_modules = {

	-- Generally required
		"disco"; -- Service discovery
		"roster"; -- Allow users to have a roster. Recommended ;)
		"saslauth"; -- Authentication for clients and servers. Recommended if you want to log in.
		"tls"; -- Add support for secure TLS on c2s/s2s connections

	-- Not essential, but recommended
		"blocklist"; -- Allow users to block communications with other users
		"carbons"; -- Keep multiple online clients in sync
		"dialback"; -- Support for verifying remote servers using DNS
		"limits"; -- Enable bandwidth limiting for XMPP connections
		"pep"; -- Allow users to store public and private data in their account
		"private"; -- Legacy account storage mechanism (XEP-0049)
		"vcard4"; -- User profiles (stored in PEP)
		"vcard_legacy"; -- Conversion between legacy vCard and PEP Avatar, vcard

	-- Nice to have
		"csi_simple"; -- Simple but effective traffic optimizations for mobile devices
		"ping"; -- Replies to XMPP pings with pongs
		"register"; -- Allow users to register on this server using a client and change passwords
		"time"; -- Let others know the time here on this server
		"uptime"; -- Report how long server has been running
		"version"; -- Replies to server version requests
		--"mam"; -- Store recent messages to allow multi-device synchronization

	-- Admin interfaces
		"admin_adhoc"; -- Allows administration via an XMPP client that supports ad-hoc commands
		--"admin_telnet"; -- Opens telnet console interface on localhost port 5582

	-- HTTP modules
		--"bosh"; -- Enable BOSH clients, aka "Jabber over HTTP"
		--"websocket"; -- XMPP over WebSockets

	-- Other specific functionality
		--"announce"; -- Send announcement to all online users
		--"groups"; -- Shared roster support
		--"legacyauth"; -- Legacy authentication. Only used by some old clients and bots.
		--"motd"; -- Send a message to users when they log in
		--"proxy65"; -- Enables a file transfer proxy service which clients behind NAT can use
		--"watchregistrations"; -- Alert admins of registrations
		--"welcome"; -- Welcome users who register accounts
}

for _, module_name in ipairs(_split(ENV_PROSODY_ENABLE_MODULES) or {}) do
	default_modules[#default_modules+1] = module_name;
end

if ENV_PROSODY_RETENTION_DAYS or ENV_PROSODY_ARCHIVE_EXPIRY_DAYS then
	default_modules[#default_modules+1] = "mam";
end

modules_enabled = default_modules

local env_disabled_modules = {};
for _, module_name in ipairs(_split(ENV_PROSODY_DISABLE_MODULES) or {}) do
	env_disabled_modules[#env_disabled_modules+1] = module_name;
end

modules_disabled = env_disabled_modules


-- Server-to-server authentication
-- Require valid certificates for server-to-server connections?
-- If false, other methods such as dialback (DNS) may be used instead.

s2s_secure_auth = ENV_PROSODY_S2S_SECURE_AUTH ~= "0"

-- Some servers have invalid or self-signed certificates. You can list
-- remote domains here that will not be required to authenticate using
-- certificates. They will be authenticated using other methods instead,
-- even when s2s_secure_auth is enabled.

--s2s_insecure_domains = { "insecure.example" }

-- Even if you disable s2s_secure_auth, you can still require valid
-- certificates for some domains by specifying a list here.

--s2s_secure_domains = { "jabber.org" }


-- Rate limits
-- Enable rate limits for incoming client and server connections. These help
-- protect from excessive resource consumption and denial-of-service attacks.

limits = {
	c2s = {
		rate = ENV_PROSODY_C2S_RATE_LIMIT or "10kb/s";
	};
	s2sin = {
		rate = ENV_PROSODY_S2S_RATE_LIMIT or "30kb/s";
	};
}

-- Authentication
-- Select the authentication backend to use. The 'internal' providers
-- use Prosody's configured data storage to store the authentication data.
-- For more information see https://prosody.im/doc/authentication

authentication = "internal_hashed"

-- Many authentication providers, including the default one, allow you to
-- create user accounts via Prosody's admin interfaces. For details, see the
-- documentation at https://prosody.im/doc/creating_accounts


-- Storage
-- Select the storage backend to use. By default Prosody uses flat files
-- in its configured data directory, but it also supports more backends
-- through modules. An "sql" backend is included by default, but requires
-- additional dependencies. See https://prosody.im/doc/storage for more info.

storage = ENV_PROSODY_SQL_DRIVER and "sql" or ENV_PROSODY_STORAGE or "internal"

-- For the "sql" backend, you can uncomment *one* of the below to configure:

if ENV_PROSODY_SQL_DRIVER then
	sql = {
		driver = ENV_PROSODY_SQL_DRIVER;
		database = ENV_PROSODY_SQL_DB;
		username = ENV_PROSODY_SQL_USERNAME;
		password = ENV_PROSODY_SQL_PASSWORD;
		host = ENV_PROSODY_SQL_HOST;
	}
end
--sql = { driver = "SQLite3", database = "prosody.sqlite" } -- Default. 'database' is the filename.
--sql = { driver = "MySQL", database = "prosody", username = "prosody", password = "secret", host = "localhost" }
--sql = { driver = "PostgreSQL", database = "prosody", username = "prosody", password = "secret", host = "localhost" }


-- Archiving configuration
-- If mod_mam is enabled, Prosody will store a copy of every message. This
-- is used to synchronize conversations between multiple clients, even if
-- they are offline. This setting controls how long Prosody will keep
-- messages in the archive before removing them.

archive_expires_after = (ENV_PROSODY_ARCHIVE_EXPIRY_DAYS or ENV_PROSODY_RETENTION_DAYS or "7").."d" -- Remove archived messages after 1 week

-- You can also configure messages to be stored in-memory only. For more
-- archiving options, see https://prosody.im/doc/modules/mod_mam


-- Logging configuration
-- For advanced logging see https://prosody.im/doc/logging
log = {
	[ENV_PROSODY_LOGLEVEL or "info"] = "*stdout";
}


-- For more info see https://prosody.im/doc/statistics
statistics = ENV_PROSODY_STATISTICS


-- Certificates
-- Every virtual host and component needs a certificate so that clients and
-- servers can securely verify its identity. Prosody will automatically load
-- certificates/keys from the directory specified here.
-- For more information, including how to use 'prosodyctl' to auto-import certificates
-- (from e.g. Let's Encrypt) see https://prosody.im/doc/certificates

-- Location of directory to find certificates in (relative to main config file):
certificates = ENV_PROSODY_CERTIFICATES or "certs"

----------- Virtual hosts -----------
-- You need to add a VirtualHost entry for each domain you wish Prosody to serve.
-- Settings under each VirtualHost entry apply *only* to that host.

local pp = require "util.pposix";
local vhosts = _split(ENV_PROSODY_VIRTUAL_HOSTS) or {pp.uname().nodename};

local network_hostname = ENV_PROSODY_NETWORK_HOSTNAME or #vhosts == 1 and vhosts[1];
if network_hostname then
	http_host = network_hostname
	proxy65_address = network_hostname
end

for _, vhost in ipairs(vhosts) do
	VirtualHost (vhost)
end

------ Components ------
-- You can specify components to add hosts that provide special services,
-- like multi-user conferences, and transports.
-- For more information on components, see https://prosody.im/doc/components

for _, component_def in ipairs(_split(ENV_PROSODY_COMPONENTS) or {}) do
	local c_name, c_type = _split(component_def, ":");
	Component (c_name) (c_type)

	if c_type == "muc" then
		modules_enabled = _split(ENV_PROSODY_MUC_MODULES)
	end
end

for _, component_def in ipairs(_split(ENV_PROSODY_EXTERNAL_COMPONENTS) or {}) do
	local c_name, c_secret = _split(component_def, ":");
	Component (c_name)
		component_secret = c_secret or ENV_PROSODY_COMPONENT_SECRET
end

---Set up a MUC (multi-user chat) room server on conference.example.com:
--Component "conference.example.com" "muc"
--- Store MUC messages in an archive and allow users to access it
--modules_enabled = { "muc_mam" }

---Set up an external component (default component port is 5347)
--
-- External components allow adding various services, such as gateways/
-- bridges to non-XMPP networks and services. For more info
-- see: https://prosody.im/doc/components#adding_an_external_component
--
--Component "gateway.example.com"
--	component_secret = "password"


---------- End of the Prosody Configuration file ----------
-- You usually **DO NOT** want to add settings here at the end, as they would
-- only apply to the last defined VirtualHost or Component.
--
-- Settings for the global section should go higher up, before the first
-- VirtualHost or Component line, while settings intended for specific hosts
-- should go under the corresponding VirtualHost or Component line.
--
-- For more information see https://prosody.im/doc/configure

Include (ENV_PROSODY_EXTRA_CONFIG or "/etc/prosody/conf.d/*.cfg.lua")
