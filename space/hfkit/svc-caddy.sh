#!/usr/bin/env bash
# Caddy front proxy — port 7860 on HF Spaces, $PORT on Render/others.
set -e
exec /usr/local/bin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
