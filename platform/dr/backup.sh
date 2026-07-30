#!/usr/bin/env bash
set -euo pipefail

umask 077

backup_root="${BACKUP_ROOT:-$HOME/university-backups}"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
work_dir="${backup_root}/university-dr-${timestamp}"
archive="${work_dir}.tar.gz"

mkdir -p "${work_dir}/kubernetes" "${work_dir}/elasticsearch"

kubectl --request-timeout=10s get namespace university-platform -o yaml \
  >"${work_dir}/kubernetes/namespace.yaml"
kubectl --request-timeout=10s -n university-platform get \
  deployments,services,configmaps,persistentvolumeclaims -o yaml \
  >"${work_dir}/kubernetes/resources.yaml"

python3 - "${work_dir}/elasticsearch/university-logs.ndjson" <<'PY'
import json
import sys
import urllib.request

output_path = sys.argv[1]
url = (
    "http://127.0.0.1:9200/university-logs-*/_search"
    "?size=10000&sort=%40timestamp%3Aasc"
)
with urllib.request.urlopen(url, timeout=30) as response:
    result = json.load(response)

with open(output_path, "w", encoding="utf-8") as output:
    for hit in result["hits"]["hits"]:
        output.write(json.dumps(hit["_source"], ensure_ascii=False) + "\n")
PY

cat >"${work_dir}/manifest.txt" <<EOF
created_at_utc=${timestamp}
hostname=$(hostname)
kubernetes_namespace=university-platform
elasticsearch_pattern=university-logs-*
secrets_included=false
EOF

(
  cd "${work_dir}"
  find . -type f ! -name SHA256SUMS -print0 |
    sort -z |
    xargs -0 sha256sum >SHA256SUMS
)

tar -C "${backup_root}" -czf "${archive}" "$(basename "${work_dir}")"
chmod 600 "${archive}"

echo "${archive}"
