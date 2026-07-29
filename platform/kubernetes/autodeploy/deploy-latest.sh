#!/usr/bin/env bash
set -Eeuo pipefail

namespace="university-platform"
registry="ghcr.io"
owner="schalich"

log() {
  printf '%s %s\n' "$(date --iso-8601=seconds)" "$*"
}

registry_digest() {
  local image="$1"
  local token
  local headers
  local digest

  token="$(
    curl --fail --silent --show-error \
      "https://${registry}/token?scope=repository:${owner}/${image}:pull" |
      sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
  )"

  if [[ -z "${token}" ]]; then
    log "ERROR: ${image} için registry token alınamadı." >&2
    return 1
  fi

  headers="$(mktemp)"
  curl --fail --silent --show-error \
    --head \
    --header "Authorization: Bearer ${token}" \
    --header "Accept: application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.v2+json" \
    --dump-header "${headers}" \
    "https://${registry}/v2/${owner}/${image}/manifests/latest" \
    >/dev/null

  digest="$(
    awk 'BEGIN { IGNORECASE=1 }
      /^docker-content-digest:/ {
        gsub("\r", "", $2)
        print $2
        exit
      }' "${headers}"
  )"
  rm -f -- "${headers}"

  if [[ ! "${digest}" =~ ^sha256:[0-9a-f]{64}$ ]]; then
    log "ERROR: ${image} için geçerli digest alınamadı." >&2
    return 1
  fi

  printf '%s\n' "${digest}"
}

deploy_if_changed() {
  local deployment="$1"
  local container="$2"
  local image="$3"
  local digest
  local desired
  local current

  digest="$(registry_digest "${image}")"
  desired="${registry}/${owner}/${image}@${digest}"
  current="$(
    kubectl get deployment "${deployment}" \
      --namespace "${namespace}" \
      --output "jsonpath={.spec.template.spec.containers[?(@.name=='${container}')].image}"
  )"

  if [[ "${current}" == "${desired}" ]]; then
    log "${deployment}: güncel (${digest})."
    return
  fi

  log "${deployment}: ${digest} sürümüne güncelleniyor."
  kubectl set image \
    "deployment/${deployment}" \
    "${container}=${desired}" \
    --namespace "${namespace}"
  kubectl rollout status \
    "deployment/${deployment}" \
    --namespace "${namespace}" \
    --timeout=180s
}

deploy_if_changed \
  "oracle-university-api" \
  "api" \
  "oracle-university-api"

deploy_if_changed \
  "oracle-university-nginx" \
  "nginx" \
  "oracle-university-nginx"

health=""
for attempt in {1..10}; do
  if health="$(
    curl --fail --silent \
      --max-time 5 \
      "http://127.0.0.1:30080/health"
  )"; then
    break
  fi

  log "Sağlık kontrolü bekleniyor (${attempt}/10)."
  sleep 3
done

if [[ -z "${health}" ]]; then
  log "ERROR: Sağlık kontrolü başarısız." >&2
  exit 1
fi

log "Sağlık kontrolü başarılı: ${health}"
