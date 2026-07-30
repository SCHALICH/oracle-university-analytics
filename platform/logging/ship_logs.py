#!/usr/bin/env python3
"""Ship recent university platform logs to the local Elasticsearch lab."""

from __future__ import annotations

import datetime as dt
import json
import subprocess
import urllib.request


ELASTICSEARCH_URL = "http://127.0.0.1:9200"
SOURCES = {
    "kong-gateway": ["podman", "logs", "--since", "65s", "kong-gateway"],
    "university-api": [
        "kubectl",
        "--request-timeout=5s",
        "logs",
        "-n",
        "university-platform",
        "deployment/university-api",
        "--since=65s",
    ],
    "university-nginx": [
        "kubectl",
        "--request-timeout=5s",
        "logs",
        "-n",
        "university-platform",
        "deployment/university-nginx",
        "--since=65s",
    ],
}


def recent_lines(command: list[str]) -> list[str]:
    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
        timeout=10,
        check=False,
    )
    output = "\n".join(part for part in (result.stdout, result.stderr) if part)
    return [line[:4000] for line in output.splitlines()[-500:] if line.strip()]


def main() -> None:
    now = dt.datetime.now(dt.timezone.utc)
    index = f"university-logs-{now:%Y.%m.%d}"
    bulk: list[str] = []

    for source, command in SOURCES.items():
        for message in recent_lines(command):
            bulk.append(json.dumps({"index": {"_index": index}}))
            bulk.append(
                json.dumps(
                    {
                        "@timestamp": now.isoformat(),
                        "service": source,
                        "environment": "devops-lab",
                        "message": message,
                    },
                    ensure_ascii=False,
                )
            )

    if not bulk:
        return

    request = urllib.request.Request(
        f"{ELASTICSEARCH_URL}/_bulk",
        data=("\n".join(bulk) + "\n").encode(),
        headers={"Content-Type": "application/x-ndjson"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        result = json.load(response)
    if result.get("errors"):
        raise RuntimeError("Elasticsearch rejected one or more log documents")


if __name__ == "__main__":
    main()
