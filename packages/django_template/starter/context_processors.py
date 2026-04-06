"""Context processors for shared template values."""

from django.conf import settings
from django.http import HttpRequest


def template_defaults(_request: HttpRequest) -> dict[str, str]:
    """Expose shared template metadata."""
    return {
        "app_name": settings.APP_NAME,
        "support_email": settings.SUPPORT_EMAIL,
    }
