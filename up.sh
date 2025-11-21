#!/usr/bin/env bash

# Usage:
#   ./up.sh /path/to/site-dir subdomain
#
# Example:
#   ./up.sh ./dist jeans

set -e

SITE_DIR="$1"
SUBDOMAIN="$2"
DOMAIN="uppies.dev"

if [ -z "$SITE_DIR" ] || [ -z "$SUBDOMAIN" ]; then
  echo "Usage: $0 <site-directory> <subdomain>"
  exit 1
fi

if [ ! -d "$SITE_DIR" ]; then
  echo "Error: Directory '$SITE_DIR' does not exist."
  exit 1
fi

HOSTNAME="${SUBDOMAIN}.${DOMAIN}"
ROUTER_NAME="${SUBDOMAIN}"
CONTAINER_NAME="${SUBDOMAIN}-site"

# Kill existing container if exists
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

docker run -d \
  --name "$CONTAINER_NAME" \
  --network uppies_net \
  -v "$(realpath "$SITE_DIR")":/usr/share/caddy:ro \
  -l traefik.enable=true \
  -l "traefik.http.routers.${ROUTER_NAME}.rule=Host(\"${HOSTNAME}\")" \
  -l "traefik.http.routers.${ROUTER_NAME}.entrypoints=websecure" \
  -l "traefik.http.routers.${ROUTER_NAME}.tls.certresolver=myresolver" \
  caddy:alpine

echo ""
echo "--------------------------------------------"
echo " Launched Uppies site"
echo "  Name:       $CONTAINER_NAME"
echo "  Hostname:   $HOSTNAME"
echo "  Directory:  $SITE_DIR"
echo ""
echo " Visit:"
echo "  https://${HOSTNAME}"
echo "--------------------------------------------"
