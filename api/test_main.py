import json

from fastapi.testclient import TestClient
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
