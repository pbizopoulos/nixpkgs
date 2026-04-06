"""Django management entrypoint."""  # noqa: INP001

import os
import sys

from django.core.management import execute_from_command_line


def main() -> None:
    """Run Django management commands."""
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "django_template.settings")
    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()
