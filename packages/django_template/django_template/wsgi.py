"""WSGI entrypoint for the Django starter project."""

import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "django_template.settings")
application = get_wsgi_application()
