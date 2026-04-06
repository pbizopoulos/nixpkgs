"""Simple cache-backed throttling helpers for auth forms."""

from dataclasses import dataclass

from django.core.cache import cache


@dataclass(frozen=True)
class RateLimit:
    """Throttle parameters for an action."""

    limit: int
    window_seconds: int
    block_seconds: int


LOGIN_RATE_LIMIT = RateLimit(limit=5, window_seconds=60, block_seconds=300)
SIGNUP_RATE_LIMIT = RateLimit(limit=3, window_seconds=60, block_seconds=600)


def throttle_submission(
    action: str,
    identifier: str,
    rate_limit: RateLimit,
) -> int | None:
    """Track attempts and return a retry delay when the action is blocked."""
    attempt_key = f"throttle:{action}:attempts:{identifier}"
    block_key = f"throttle:{action}:blocked:{identifier}"
    if cache.get(block_key):
        return rate_limit.block_seconds
    attempts = cache.get(attempt_key, 0)
    if attempts >= rate_limit.limit:
        cache.set(block_key, 1, timeout=rate_limit.block_seconds)
        return rate_limit.block_seconds
    cache.set(attempt_key, attempts + 1, timeout=rate_limit.window_seconds)
    return None
