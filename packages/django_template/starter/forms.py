"""Forms for the Django starter authentication flows."""

from typing import cast

from django import forms
from django.contrib.auth import get_user_model
from django.contrib.auth.forms import UserCreationForm


class RegistrationForm(UserCreationForm):  # type: ignore[misc]
    """Registration form backed by Django's built-in user model."""

    class Meta(UserCreationForm.Meta):  # type: ignore[misc]
        """Bind the registration form to the configured user model."""

        model = get_user_model()
        fields = ("username", "email", "password1", "password2")

    email = forms.EmailField(required=True)

    def clean_email(self) -> str:
        """Reject duplicate email addresses."""
        email = cast("str", self.cleaned_data["email"]).strip().lower()
        if get_user_model().objects.filter(email__iexact=email).exists():
            msg = "This value is already taken."
            raise forms.ValidationError(msg)
        return email

    def save(self, commit: bool = True) -> object:  # noqa: FBT001, FBT002
        """Persist the user with the normalized email address."""
        user = super().save(commit=False)
        user.email = cast("str", self.cleaned_data["email"])
        if commit:
            user.save()
        return user


class LoginForm(forms.Form):  # type: ignore[misc]
    """Login form that accepts either username or email."""

    login = forms.CharField(label="Email or username", max_length=254)
    password = forms.CharField(
        label="Password",
        strip=False,
        widget=forms.PasswordInput,
    )
