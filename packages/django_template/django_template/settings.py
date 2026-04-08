"""Django settings for the starter template."""

import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent


def split_csv_env(name: str, default: str) -> list[str]:
    """Split a comma-separated environment variable into trimmed values."""
    return [
        item.strip() for item in os.getenv(name, default).split(",") if item.strip()
    ]


def database_settings() -> dict[str, str]:
    """Build the Django database settings from environment variables."""
    engine_name = os.getenv("DATABASE_ENGINE", "postgresql")
    if engine_name == "postgresql":
        return {
            "ENGINE": "django.db.backends.postgresql",
            "HOST": os.getenv("DB_HOST", "/run/postgresql"),
            "NAME": os.getenv("DATABASE_NAME", "django_template"),
            "PASSWORD": os.getenv("DB_PASSWORD", ""),
            "PORT": os.getenv("DB_PORT", "5432"),
            "USER": os.getenv("DB_USER", "django_template"),
        }
    return {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": os.getenv("DATABASE_NAME", str(BASE_DIR / "tmp" / "db.sqlite3")),
    }


SECRET_KEY = os.getenv("SECRET_KEY", "django-insecure-template-secret-key")
DEBUG = os.getenv("DJANGO_DEBUG", os.getenv("DEBUG", "0")) == "1"
ALLOWED_HOSTS = split_csv_env("ALLOWED_HOSTS", "127.0.0.1,localhost,[::1],testserver")
CSRF_TRUSTED_ORIGINS = split_csv_env("CSRF_TRUSTED_ORIGINS", "")
APP_NAME = os.getenv("APP_NAME", "Django Starter")
SUPPORT_EMAIL = os.getenv("SUPPORT_EMAIL", "support@example.com")
INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "starter",
]
MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]
ROOT_URLCONF = "django_template.urls"
TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
                "starter.context_processors.template_defaults",
            ],
        },
    },
]
WSGI_APPLICATION = "django_template.wsgi.application"
DATABASES = {"default": database_settings()}
AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": (
            "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"
        ),
    },
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
]
LANGUAGE_CODE = "en-us"
TIME_ZONE = os.getenv("TZ", "UTC")
USE_I18N = True
USE_TZ = True
STATIC_URL = "/static/"
STATIC_ROOT = Path(os.getenv("STATIC_ROOT", str(BASE_DIR / "staticfiles")))
STATICFILES_DIRS = [BASE_DIR / "static"]
STORAGES = {
    "staticfiles": {
        "BACKEND": "whitenoise.storage.CompressedStaticFilesStorage",
    },
}
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
LOGIN_URL = "login"
LOGIN_REDIRECT_URL = "dashboard"
LOGOUT_REDIRECT_URL = "home"
AUTHENTICATION_BACKENDS = [
    "starter.auth_backends.EmailOrUsernameBackend",
    "django.contrib.auth.backends.ModelBackend",
]
EMAIL_BACKEND = os.getenv(
    "EMAIL_BACKEND",
    "django.core.mail.backends.console.EmailBackend",
)
DEFAULT_FROM_EMAIL = os.getenv("DEFAULT_FROM_EMAIL", "starter@example.com")
