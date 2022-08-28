# AriaNg Utilities

Build and serve [AriaNg](https://github.com/mayswind/AriaNg) easily.

## Prerequisites

1. Install [caddy](https://caddyserver.com/docs/install), include the
   `caddy-dns/cloudflare` plugin if CloudFlare will be used as ACME DNS provider
   (shown in the final example).
1. Install Docker
1. Install and run aria2, enable RPC on port 6800; do NOT set RPC secret.
   An example of Aria2 startup script:

   ```sh
   aria2c --enable-rpc --rpc-listen-all=false --rpc-listen-port 6800 \
    --max-connection-per-server=10 --rpc-max-request-size=1024M \
    --seed-time=0.01 --min-split-size=10M --follow-torrent=mem --split=10 \
    --daemon=true --allow-overwrite=true --max-overall-download-limit=0 \
    --max-overall-upload-limit=1K --max-concurrent-downloads=10 \
    --rpc-allow-origin-all=true --dir=/bt
   ```
   **Note** It's very dangerous to expose unprotected JSON RPC to public
   Internet. **Always** enalbe auth and HTTPS, keep reading till the final
   example.

## Clone the repo

To make sure the caddy server has read access to artificials, clone this repo
somewhere that caddy can read, e.g.:

```sh
git clone https://github.com/genzj/ariang-util.git /var/lib/ariang-util
chown -R root:caddy /var/lib/ariang-util
```

## Build

Enter repo dir then execute:

```sh
cd /var/lib/ariang-util
make build
```

## Serve

Edit your Caddyfile, normally `/etc/caddy/Caddyfile` to add an import directive
and a server section for AriaNg:

```
import /var/lib/ariang-util/Caddyfile

your.server.domain {
    # Other directives, such as basicauth, tls, etc
    # ...

    # set the root to util repo so that the AriaNg artificials can be correctly
    # located
    root * /var/lib/ariang-util

    # apply the ariang snippet, which is defined in
    # the /var/lib/ariang-util/Caddyfile
    import ariang
}
```

## Final Example

A working site with basicauth and ACME DNS (provided by CloudFlare) TLS

`/etc/caddy/Caddyfile`:

```
{
        # global ACME DNS is enabled in this example. For per-site TLS
        # configuration, please refer to Caddy doc.
        acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
}

import /var/lib/ariang-util/Caddyfile

aria.genzj.info {
        basicauth {
                # read https://caddyserver.com/docs/caddyfile/directives/basicauth 
                # to learn how to add users
        }
        root * /var/lib/ariang-util
        import ariang
}
```

`/etc/systemd/system/caddy.service.d`:

```
[Service]
# Read https://developers.cloudflare.com/api/tokens/create/ to create your token
Environment=CLOUDFLARE_API_TOKEN=<some-secret-token>
```
