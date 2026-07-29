"""Oracle University Analytics REST API."""

import json
import os
from typing import Literal
from uuid import uuid4

import pika
from fastapi import FastAPI, HTTPException, status
from pika.exceptions import AMQPError
from pydantic import BaseModel, Field
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

rabbitmq_url = os.getenv(
    "RABBITMQ_URL",
    "amqp://guest:guest@rabbitmq:5672/%2F",
)
rabbitmq_queue = os.getenv("RABBITMQ_QUEUE", "university.tasks")


class TaskRequest(BaseModel):
    """Describe a background analytics task."""

    task_type: Literal[
        "grade-report",
        "sales-forecast",
        "student-risk-analysis",
    ]
    payload: dict[str, object] = Field(default_factory=dict)


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


def publish_task(task: TaskRequest) -> str:
    """Publish a durable analytics task to RabbitMQ."""
    message_id = str(uuid4())
    parameters = pika.URLParameters(rabbitmq_url)
    parameters.socket_timeout = 3
    parameters.blocked_connection_timeout = 3
    parameters.connection_attempts = 1

    connection = pika.BlockingConnection(parameters)
    try:
        channel = connection.channel()
        channel.queue_declare(queue=rabbitmq_queue, durable=True)
        channel.basic_publish(
            exchange="",
            routing_key=rabbitmq_queue,
            body=json.dumps(
                {
                    "message_id": message_id,
                    "task_type": task.task_type,
                    "payload": task.payload,
                }
            ).encode(),
            properties=pika.BasicProperties(
                content_type="application/json",
                delivery_mode=pika.DeliveryMode.Persistent,
                message_id=message_id,
            ),
        )
    finally:
        if connection.is_open:
            connection.close()

    return message_id


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


@app.post(
    "/api/v1/tasks",
    tags=["Tasks"],
    status_code=status.HTTP_202_ACCEPTED,
)
def create_task(task: TaskRequest) -> dict[str, str]:
    """Place an analytics task on the RabbitMQ work queue."""
    try:
        message_id = publish_task(task)
    except AMQPError as error:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Task queue is temporarily unavailable",
        ) from error

    return {
        "status": "queued",
        "message_id": message_id,
        "task_type": task.task_type,
    }
