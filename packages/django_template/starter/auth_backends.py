"""Authentication backends for the Django starter."""

from django.contrib.auth import get_user_model
from django.contrib.auth.backends import ModelBackend
from django.db.models import Q
from django.http import HttpRequest


class EmailOrUsernameBackend(ModelBackend):  # type: ignore[misc]
    """Allow users to authenticate with either username or email."""

    def authenticate(
        self,
        request: HttpRequest | None,  # noqa: ARG002
        username: str | None = None,
        password: str | None = None,
        login: str | None = None,
        **kwargs: object,
    ) -> object | None:
        """Authenticate a user against username or email credentials."""
        identifier = login or username or kwargs.get(get_user_model().USERNAME_FIELD)
        if not identifier or not password:
            return None
        user_model = get_user_model()
        user = (
            user_model.objects.filter(
                Q(username__iexact=identifier) | Q(email__iexact=identifier),
            )
            .order_by("pk")
            .first()
        )
        if user is None:
            user_model().set_password(password)
            return None
        if user.check_password(password) and self.user_can_authenticate(user):
            return user  # type: ignore[no-any-return]
        return None
