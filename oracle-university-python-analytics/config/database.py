"""Oracle connection factory configured through environment variables."""

import os

import oracledb


def _required_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Required environment variable is missing: {name}")
    return value


def get_connection() -> oracledb.Connection:
    """Create an Oracle connection without storing credentials in source code."""
    return oracledb.connect(
        user=_required_env("ORACLE_USER"),
        password=_required_env("ORACLE_PASSWORD"),
        dsn=_required_env("ORACLE_DSN"),
    )
