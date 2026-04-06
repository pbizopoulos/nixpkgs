"""View tests for the Django starter application."""

from django.contrib.auth import get_user_model
from django.core import mail
from django.core.cache import cache
from django.test import TestCase, override_settings
from django.urls import reverse

TEST_PASSWORD = "S3cure-pass-1234"  # noqa: S105


class StarterViewTests(TestCase):  # type: ignore[misc]
    """Functional coverage for the starter's core views."""

    def setUp(self) -> None:
        """Reset cache state before each test."""
        cache.clear()

    def test_visitor_sees_the_full_starter_landing_page(self) -> None:
        """Show the visitor-facing landing page content."""
        response = self.client.get(reverse("home"))
        self.assertContains(response, "Build the app, not the scaffold.")
        self.assertContains(
            response,
            "This template uses the conventional Django stack:",
        )
        self.assertContains(response, "authentication, CSRF, mail, and health checks")
        self.assertContains(response, reverse("register"))
        self.assertContains(response, reverse("login"))
        self.assertContains(response, "https://docs.djangoproject.com/")

    def test_registration_login_logout_and_account_deletion_work(self) -> None:
        """Exercise the full account lifecycle."""
        registration = self.client.post(
            reverse("register"),
            {
                "username": "starter-user",
                "email": "starter@example.com",
                "password1": TEST_PASSWORD,
                "password2": TEST_PASSWORD,
            },
            follow=True,
        )
        self.assertRedirects(registration, reverse("dashboard"))
        self.assertContains(registration, "starter-user")
        self.assertContains(registration, "starter@example.com")
        self.assertEqual(len(mail.outbox), 1)  # noqa: PT009
        logout_response = self.client.post(reverse("logout"), follow=True)
        self.assertRedirects(logout_response, reverse("home"))
        login_response = self.client.post(
            reverse("login"),
            {"login": "starter@example.com", "password": TEST_PASSWORD},
            follow=True,
        )
        self.assertRedirects(login_response, reverse("dashboard"))
        self.assertContains(login_response, "Welcome back")
        delete_response = self.client.post(reverse("account-delete"), follow=True)
        self.assertRedirects(delete_response, reverse("home"))
        self.assertContains(delete_response, "account has been deleted")
        self.assertFalse(  # noqa: PT009
            get_user_model().objects.filter(username="starter-user").exists(),
        )

    def test_login_accepts_username_as_well_as_email(self) -> None:
        """Support username-based login in addition to email."""
        get_user_model().objects.create_user(
            username="username-login",
            email="username-login@example.com",
            password=TEST_PASSWORD,
        )
        response = self.client.post(
            reverse("login"),
            {"login": "username-login", "password": TEST_PASSWORD},
            follow=True,
        )
        self.assertRedirects(response, reverse("dashboard"))
        self.assertContains(response, "Welcome back, username-login.")

    def test_registration_validation_errors_are_shown(self) -> None:
        """Render validation feedback for invalid signup submissions."""
        response = self.client.post(
            reverse("register"),
            {
                "username": "bad username",
                "email": "valid@example.com",
                "password1": "short",
                "password2": "short",
            },
        )
        self.assertEqual(response.status_code, 200)  # noqa: PT009
        self.assertContains(
            response,
            "This password is too short. It must contain at least 8 characters.",
        )

    def test_invalid_login_keeps_the_visitor_on_the_login_form(self) -> None:
        """Keep the visitor on the login form after invalid credentials."""
        response = self.client.post(
            reverse("login"),
            {"login": "missing@example.com", "password": "password123"},
        )
        self.assertEqual(response.status_code, 200)  # noqa: PT009
        self.assertContains(response, "The credentials you entered are invalid.")

    def test_signup_is_rate_limited(self) -> None:
        """Throttle repeated signup attempts from the same client."""
        for _ in range(3):
            response = self.client.post(
                reverse("register"),
                {
                    "username": "bad username",
                    "email": "valid@example.com",
                    "password1": "short",
                    "password2": "short",
                },
            )
            self.assertEqual(response.status_code, 200)  # noqa: PT009
        blocked_response = self.client.post(
            reverse("register"),
            {
                "username": "bad username",
                "email": "valid@example.com",
                "password1": "short",
                "password2": "short",
            },
        )
        self.assertEqual(blocked_response.status_code, 429)  # noqa: PT009
        self.assertContains(
            blocked_response,
            "Too many signup attempts.",
            status_code=429,
        )

    def test_login_is_rate_limited(self) -> None:
        """Throttle repeated login attempts from the same client."""
        for _ in range(5):
            response = self.client.post(
                reverse("login"),
                {"login": "missing@example.com", "password": "password123"},
            )
            self.assertEqual(response.status_code, 200)  # noqa: PT009
        blocked_response = self.client.post(
            reverse("login"),
            {"login": "missing@example.com", "password": "password123"},
        )
        self.assertEqual(blocked_response.status_code, 429)  # noqa: PT009
        self.assertContains(
            blocked_response,
            "Too many login attempts.",
            status_code=429,
        )

    def test_authenticated_visitors_see_their_current_session_summary_on_the_home_page(
        self,
    ) -> None:
        """Show current-session details on the landing page for signed-in users."""
        get_user_model().objects.create_user(
            username="home-user",
            email="home@example.com",
            password=TEST_PASSWORD,
        )
        self.client.post(
            reverse("login"),
            {"login": "home@example.com", "password": TEST_PASSWORD},
        )
        response = self.client.get(reverse("home"))
        self.assertContains(response, "Current session")
        self.assertContains(response, "home-user")
        self.assertContains(response, "home@example.com")

    def test_health_check_reports_the_database_dependency_as_healthy(self) -> None:
        """Return a healthy status when the database is reachable."""
        response = self.client.get(reverse("health"))
        self.assertEqual(response.status_code, 200)  # noqa: PT009
        payload = response.json()
        self.assertTrue(payload["isHealthy"])  # noqa: PT009
        self.assertTrue(payload["checks"]["database"]["healthy"])  # noqa: PT009

    def test_guests_are_redirected_to_login_for_the_dashboard(self) -> None:
        """Redirect unauthenticated visitors away from the dashboard."""
        response = self.client.get(reverse("dashboard"))
        self.assertRedirects(
            response,
            f"{reverse('login')}?next={reverse('dashboard')}",
        )


class NotFoundTests(TestCase):  # type: ignore[misc]
    """Coverage for production and debug 404 behavior."""

    def setUp(self) -> None:
        """Reset cache state before each test."""
        cache.clear()

    @override_settings(DEBUG=False)  # type: ignore[untyped-decorator]
    def test_production_not_found_page_is_conventional(self) -> None:
        """Use the template-backed 404 page in non-debug mode."""
        response = self.client.get("/totally-fake-route-that-does-not-exist-xyz123")
        self.assertEqual(response.status_code, 404)  # noqa: PT009
        self.assertContains(response, "Page Not Found", status_code=404)

    @override_settings(DEBUG=True)  # type: ignore[untyped-decorator]
    def test_debug_not_found_page_shows_the_requested_path(self) -> None:
        """Expose the requested path in Django's debug 404 page."""
        response = self.client.get("/totally-fake-route-that-does-not-exist-xyz123")
        self.assertEqual(response.status_code, 404)  # noqa: PT009
        self.assertContains(response, "The current path,", status_code=404)
        self.assertContains(
            response,
            "totally-fake-route-that-does-not-exist-xyz123",
            status_code=404,
        )
