"""Authentication backend tests for the Django starter."""

from django.contrib.auth import authenticate, get_user_model
from django.test import TestCase

TEST_PASSWORD = "S3cure-pass-1234"  # noqa: S105


class EmailOrUsernameBackendTests(TestCase):  # type: ignore[misc]
    """Coverage for the email-or-username authentication backend."""

    def test_authenticates_with_email(self) -> None:
        """Allow authentication with an email address."""
        user = get_user_model().objects.create_user(
            username="starter-user",
            email="starter@example.com",
            password=TEST_PASSWORD,
        )
        authenticated = authenticate(
            login="starter@example.com",
            password=TEST_PASSWORD,
        )
        self.assertEqual(authenticated, user)  # noqa: PT009
