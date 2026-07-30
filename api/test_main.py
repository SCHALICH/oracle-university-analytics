import json

from fastapi.testclient import TestClient
from minio.error import S3Error
from pika.exceptions import AMQPConnectionError
from redis.exceptions import RedisError

import main


client = TestClient(main.app)


class FakeRedis:
    def __init__(self, cached_value: str | None = None, unavailable: bool = False):
        self.cached_value = cached_value
        self.unavailable = unavailable

    def ping(self) -> bool:
        if self.unavailable:
            raise RedisError("Redis is unavailable")
        return True

    def get(self, _key: str) -> str | None:
        if self.unavailable:
            raise RedisError("Redis is unavailable")
        return self.cached_value

    def setex(self, _key: str, _ttl: int, value: str) -> bool:
        if self.unavailable:
            raise RedisError("Redis is unavailable")
        self.cached_value = value
        return True


def test_health_reports_redis_up(monkeypatch):
    monkeypatch.setattr(main, "redis_client", FakeRedis())

    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {
        "status": "ok",
        "service": "oracle-university-api",
        "redis": "up",
    }


def test_project_cache_miss_then_hit(monkeypatch):
    fake_redis = FakeRedis()
    monkeypatch.setattr(main, "redis_client", fake_redis)

    first_response = client.get("/api/v1/project")
    second_response = client.get("/api/v1/project")

    assert first_response.status_code == 200
    assert first_response.json()["cache"] == "miss"
    assert second_response.status_code == 200
    assert second_response.json()["cache"] == "hit"
    assert json.loads(fake_redis.cached_value)["name"] == "Oracle University Analytics"


def test_api_remains_available_when_redis_is_down(monkeypatch):
    monkeypatch.setattr(main, "redis_client", FakeRedis(unavailable=True))

    health_response = client.get("/health")
    project_response = client.get("/api/v1/project")

    assert health_response.status_code == 200
    assert health_response.json()["redis"] == "unavailable"
    assert project_response.status_code == 200
    assert project_response.json()["cache"] == "unavailable"


def test_task_is_published_to_rabbitmq(monkeypatch):
    monkeypatch.setattr(main, "publish_task", lambda _task: "message-123")

    response = client.post(
        "/api/v1/tasks",
        json={
            "task_type": "sales-forecast",
            "payload": {"months": 3},
        },
    )

    assert response.status_code == 202
    assert response.json() == {
        "status": "queued",
        "message_id": "message-123",
        "task_type": "sales-forecast",
    }


def test_task_endpoint_reports_rabbitmq_outage(monkeypatch):
    def unavailable(_task):
        raise AMQPConnectionError("RabbitMQ is unavailable")

    monkeypatch.setattr(main, "publish_task", unavailable)

    response = client.post(
        "/api/v1/tasks",
        json={
            "task_type": "grade-report",
            "payload": {},
        },
    )

    assert response.status_code == 503
    assert response.json() == {
        "detail": "Task queue is temporarily unavailable",
    }


def test_report_is_stored_in_minio(monkeypatch):
    monkeypatch.setattr(
        main,
        "store_report",
        lambda _report: "report-id-analysis.md",
    )

    response = client.post(
        "/api/v1/reports",
        json={
            "filename": "analysis.md",
            "content": "# University report",
            "content_type": "text/markdown",
        },
    )

    assert response.status_code == 201
    assert response.json() == {
        "status": "stored",
        "bucket": "university-reports",
        "object_name": "report-id-analysis.md",
    }


def test_report_endpoint_reports_minio_outage(monkeypatch):
    def unavailable(_report):
        raise S3Error(
            code="ServiceUnavailable",
            message="MinIO is unavailable",
            resource=None,
            request_id=None,
            host_id=None,
            response=None,
        )

    monkeypatch.setattr(main, "store_report", unavailable)

    response = client.post(
        "/api/v1/reports",
        json={
            "filename": "analysis.txt",
            "content": "University report",
        },
    )

    assert response.status_code == 503
    assert response.json() == {
        "detail": "Report storage is temporarily unavailable",
    }


def test_identity_endpoint_requires_bearer_token():
    response = client.get("/api/v1/me")

    assert response.status_code == 401
    assert response.json() == {"detail": "Authentication is required"}


def test_identity_endpoint_returns_keycloak_user(monkeypatch):
    monkeypatch.setattr(
        main,
        "decode_access_token",
        lambda _token: {
            "preferred_username": "demo-student",
            "email": "demo-student@university.local",
            "realm_access": {"roles": ["student"]},
        },
    )

    response = client.get(
        "/api/v1/me",
        headers={"Authorization": "Bearer valid-token"},
    )

    assert response.status_code == 200
    assert response.json()["username"] == "demo-student"
    assert response.json()["roles"] == ["student"]


def test_admin_endpoint_rejects_student_role(monkeypatch):
    monkeypatch.setattr(
        main,
        "decode_access_token",
        lambda _token: {
            "preferred_username": "demo-student",
            "realm_access": {"roles": ["student"]},
        },
    )

    response = client.get(
        "/api/v1/admin/status",
        headers={"Authorization": "Bearer valid-token"},
    )

    assert response.status_code == 403
    assert response.json() == {
        "detail": "University administrator role is required",
    }


def test_admin_endpoint_accepts_administrator_role(monkeypatch):
    monkeypatch.setattr(
        main,
        "decode_access_token",
        lambda _token: {
            "preferred_username": "demo-admin",
            "realm_access": {"roles": ["university-admin"]},
        },
    )

    response = client.get(
        "/api/v1/admin/status",
        headers={"Authorization": "Bearer valid-token"},
    )

    assert response.status_code == 200
    assert response.json() == {
        "status": "authorized",
        "username": "demo-admin",
        "role": "university-admin",
    }
