"""Oracle University Analytics REST API."""

from fastapi import FastAPI


app = FastAPI(
    title="Oracle University Analytics API",
    version="1.0.0",
    description="University analytics platform service endpoints.",
)


@app.get("/health", tags=["Operations"])
def health() -> dict[str, str]:
    """Return a lightweight container health response."""
    return {"status": "ok", "service": "oracle-university-api"}


@app.get("/api/v1/project", tags=["Project"])
def project() -> dict[str, object]:
    """Describe the current project scope."""
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
