#!/usr/bin/env bash
set -euo pipefail

archive="${1:?Usage: verify_backup.sh /path/to/university-dr-*.tar.gz}"
verify_dir="$(mktemp -d)"
trap 'rm -rf "${verify_dir}"' EXIT

tar -xzf "${archive}" -C "${verify_dir}"
backup_dir="$(find "${verify_dir}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"

test -f "${backup_dir}/manifest.txt"
test -f "${backup_dir}/kubernetes/namespace.yaml"
test -f "${backup_dir}/kubernetes/resources.yaml"
test -f "${backup_dir}/elasticsearch/university-logs.ndjson"

(
  cd "${backup_dir}"
  sha256sum --check SHA256SUMS
)

echo "Backup verification successful: ${archive}"

