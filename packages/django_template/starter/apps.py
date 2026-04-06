"""App configuration for the Django starter."""

from django.apps import AppConfig


class StarterConfig(AppConfig):  # type: ignore[misc]
    """Register the starter app with Django."""

    default_auto_field = "django.db.models.BigAutoField"
    name = "starter"
