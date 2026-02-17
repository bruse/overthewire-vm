#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="${SCRIPT_DIR}/lima-behemoth-x64.yaml"
INSTANCE_NAME="${LIMA_INSTANCE_NAME:-lima-behemoth-x64}"
HOST_BEHEMOTH_DIR="${SCRIPT_DIR}"
TMP_YAML="$(mktemp "${TMPDIR:-/tmp}/lima-behemoth-x64.XXXXXX")"

cleanup() {
  rm -f "${TMP_YAML}"
}
trap cleanup EXIT

awk -v host="${HOST_BEHEMOTH_DIR}" '
  /^mounts:/ { in_mounts=1; print; next }
  in_mounts && $1 == "-" && $2 == "location:" {
    print "- location: \"" host "\""
    in_mounts=0
    next
  }
  { print }
' "${TEMPLATE}" > "${TMP_YAML}"

exec limactl start --name "${INSTANCE_NAME}" "${TMP_YAML}" "$@"
