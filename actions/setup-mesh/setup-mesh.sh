#!/usr/bin/env bash
# MODE, WG_PRIVATE_KEY, WG_SERVER_PUBLIC_KEY, WG_ENDPOINT, WG_ADDRESS, WG_ALLOWED_IPS, CHECK_ADDRESS, CHECK_TIMEOUT
set -euo pipefail

trim() { printf '%s' "$1" | tr -d '[:space:]'; }

wireguard() {
  : "${WG_PRIVATE_KEY:?wg-private-key is required}"
  : "${WG_SERVER_PUBLIC_KEY:?wg-server-public-key is required}"
  : "${WG_ENDPOINT:?wg-endpoint is required}"
  : "${WG_ADDRESS:?wg-address is required}"
  : "${WG_ALLOWED_IPS:?wg-allowed-ips is required}"

  local dir="${RUNNER_TEMP:-/tmp}/wg"
  echo "::add-mask::$(trim "$WG_PRIVATE_KEY")"

  if ! command -v wg-quick >/dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq --no-install-recommends wireguard-tools
  fi

  mkdir -p "$dir"
  chmod 700 "$dir"
  trim "$WG_PRIVATE_KEY" >"$dir/private.key"
  chmod 600 "$dir/private.key"
  {
    echo "[Interface]"
    echo "Address = $(trim "$WG_ADDRESS")"
    echo "PostUp = wg set %i private-key ${dir}/private.key"
    echo
    echo "[Peer]"
    echo "PublicKey = $(trim "$WG_SERVER_PUBLIC_KEY")"
    echo "Endpoint = $(trim "$WG_ENDPOINT")"
    echo "AllowedIPs = $(printf '%s' "$WG_ALLOWED_IPS" | tr -d '\r\n\t')"
    echo "PersistentKeepalive = 25"
  } >"$dir/wg0.conf"
  chmod 600 "$dir/wg0.conf"
  sudo wg-quick up "$dir/wg0.conf"
}

check() {
  local address host port deadline
  address="$(trim "${CHECK_ADDRESS:-}")"
  if [[ -z "$address" ]]; then
    return 0
  fi
  host="${address%:*}"
  port="${address##*:}"
  deadline=$((SECONDS + ${CHECK_TIMEOUT:-60}))
  while ((SECONDS < deadline)); do
    if timeout 5 bash -c "exec 3<>/dev/tcp/${host}/${port}" 2>/dev/null; then
      echo "mesh up: ${address} reachable"
      return 0
    fi
    sleep 2
  done
  echo "::error::${address} is not reachable through the mesh."
  sudo wg show 2>/dev/null | grep -v 'private key' >&2 || true
  return 1
}

case "${MODE:-}" in
  wireguard)
    wireguard
    ;;
  tailscale)
    echo "::error::Mode tailscale is not implemented yet."
    exit 1
    ;;
  *)
    echo "::error::Unknown mode: ${MODE:-}. Use wireguard."
    exit 1
    ;;
esac
check
