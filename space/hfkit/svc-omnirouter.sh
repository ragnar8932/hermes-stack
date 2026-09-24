#!/usr/bin/env bash
# OmniRouter (Godde3s) — keyless web models. NOT exposed publicly;
# used by Hermes as the "omnirouter" provider and can be chained
# inside 9Router as a custom provider (http://127.0.0.1:8080/v1).
#
# Slim-host guard: on Render Free (512 MB) the full stack does not fit
# in RAM, so OmniRouter stays OFF unless explicitly enabled:
#   OMNI_ENABLED=true  -> start (HF / bigger hosts)
#   OMNI_ENABLED=false -> skip (Render Free default, see render.yaml)
set -e

if [ "${OMNI_ENABLED:-true}" != "true" ]; then
    echo "[omnirouter] OMNI_ENABLED != true — staying off (slim mode)."
    # Sleep forever so the supervisor keeps this slot parked without
    # crash-looping. Any real start is done by flipping OMNI_ENABLED.
    exec sleep infinity
fi

D=/opt/data/omnirouter
mkdir -p "$D"
cd "$D"

# write .env exactly like upstream start.sh does
{
    echo "PORT=8080"
    echo "ADMIN_PASSWORD=${OMNI_ADMIN_PASSWORD:-admin}"
    echo "AGENT_MODE=1"
    if [ -n "${OMNI_ROUTER_KEY:-}" ]; then
        echo "ROUTER_KEY=${OMNI_ROUTER_KEY}"
    fi
    if [ -n "${OMNI_AUTO_CHAIN:-}" ]; then
        echo "AUTO_CHAIN=${OMNI_AUTO_CHAIN}"
    fi
} > .env

export QWEN_BX_FILE=qwen-bx.json

# Qwen guest mode needs Baxia headers on datacenter IPs (HF = datacenter).
# Do it once per data dir; retry next boot if it failed.
if [ ! -f qwen-bx.json ]; then
    timeout 90 /opt/omnirouter/qwen-bx-linux-amd64 >/dev/null 2>&1 || true
fi

exec /opt/omnirouter/omnirouter-linux-amd64
