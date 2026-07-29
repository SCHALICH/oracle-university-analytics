"""Oracle University Analytics REST API."""

import json
import os

from fastapi import FastAPI
from redis import Redis
from redis.exceptions import RedisError


app = FastAPI(
    title="Oracle University Analytics API",
    version="1.0.0",
    description="University analytics platform service endpoints.",
)

redis_client = Redis.from_url(
    os.getenv("REDIS_URL", "redis://redis:6379/0"),
    decode_responses=True,
    socket_connect_timeout=2,
    socket_timeout=2,
)


def project_payload() -> dict[str, object]:
    """Build the stable project description payload."""
    return {
        "name": "Oracle University Analytics",
        "database": ["Oracle Database 19c", "Oracle AI Database 26ai"],
        "capabilities": [
            "university information model",
            "SQL and PL/SQL analytics",
            "Random Forest",
            "SARIMAX",
        ],
    }


@app.get("/health", tags=["Operations"])
def health() -> dict[str, str]:
    """Return a lightweight container health response."""
    try:
        redis_client.ping()
        redis_status = "up"
    except RedisError:
        redis_status = "unavailable"
    return {
        "status": "ok",
        "service": "oracle-university-api",
        "redis": redis_status,
    }


@app.get("/api/v1/project", tags=["Project"])
def project() -> dict[str, object]:
    """Describe the current project scope."""
    cache_key = "oracle-university:project:v1"
    try:
        cached = redis_client.get(cache_key)
        if cached:
            return {**json.loads(cached), "cache": "hit"}
        payload = project_payload()
        redis_client.setex(cache_key, 300, json.dumps(payload))
        return {**payload, "cache": "miss"}
    except RedisError:
        return {**project_payload(), "cache": "unavailable"}


@app.get("/api/v1/platform", tags=["Platform"])
def platform() -> dict[str, list[str]]:
    """Return the planned enterprise platform layers."""
    return {
        "delivery": ["GitLab/Jenkins", "SonarQube", "Harbor/Nexus", "Kubernetes"],
        "security": ["Keycloak", "Vault", "DevSecOps"],
        "data_services": ["Redis", "RabbitMQ", "MinIO"],
        "observability": ["Prometheus", "Grafana", "Kibana", "Dynatrace"],
        "operations": ["IaC", "DR", "7/24 operations"],
    }
