#!/usr/bin/env bash
#
# Build the Remote Desktop Manager flatpak locally and update the repo.
#
# Usage: ./build-local.sh <lts|current>
#
set -euo pipefail

APP_ID="com.devolutions.remotedesktopmanager"

usage() {
    echo "Usage: $0 <lts|current>" >&2
    exit 1
}

# Require exactly one argument: the variant to build.
if [[ $# -ne 1 ]]; then
    usage
fi

VARIANT="$1"

case "$VARIANT" in
    lts|current) ;;
    *)
        echo "Error: unknown variant '$VARIANT' (expected 'lts' or 'current')." >&2
        usage
        ;;
esac

# Resolve the script's directory so it works regardless of the current directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${APP_ID}.${VARIANT}.yml"

if [[ ! -f "${SCRIPT_DIR}/${MANIFEST}" ]]; then
    echo "Error: manifest '${MANIFEST}' not found in ${SCRIPT_DIR}." >&2
    exit 1
fi

cd "$SCRIPT_DIR"

echo "==> Building ${VARIANT} variant from ${MANIFEST}"
flatpak-builder \
    --force-clean \
    --repo=repo \
    build-dir \
    "$MANIFEST"

echo "==> Updating repo and generating static deltas"
flatpak build-update-repo --generate-static-deltas repo

echo "==> Done."
