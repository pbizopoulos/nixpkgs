# ruff: noqa: INP001
"""FastAPI starter application."""

from __future__ import annotations

import os
import resource
import secrets
import unittest
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from time import time
from typing import TYPE_CHECKING, Annotated, Any, cast

import uvicorn
from fastapi import FastAPI, Form, Request, status
from fastapi.responses import HTMLResponse, JSONResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.testclient import TestClient
from sqlalchemy import DateTime, String, create_engine, func, select, text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import (
    Mapped,
    Session,
    declarative_base,
    mapped_column,
    sessionmaker,
)
from starlette.middleware.sessions import SessionMiddleware
from werkzeug.security import check_password_hash, generate_password_hash

if TYPE_CHECKING:
    from sqlalchemy.engine import Engine
Base = declarative_base()
LOGIN_RATE_LIMIT = (5, 60, 300)
SIGNUP_RATE_LIMIT = (3, 60, 600)
HTTP_OK = 200
HTTP_SEE_OTHER = 303
HTTP_NOT_FOUND = 404
HTTP_TOO_MANY_REQUESTS = 429
MIN_PASSWORD_LENGTH = 8
MEMORY_WARN_THRESHOLD_MB = 400
MEMORY_FAIL_THRESHOLD_MB = 600
PACKAGE_ROOT = Path(__file__).resolve().parent
PRM_ROOT = PACKAGE_ROOT / "prm"
TEMPLATES = Jinja2Templates(directory=str(PRM_ROOT / "templates"))
TEST_SECRET_KEY = "fastapi-template-secret-key"  # noqa: S105


@dataclass(frozen=True)
class RateLimit:
    """A fixed-window rate limit."""

    attempts: int
    window_seconds: int
    block_seconds: int


class ThrottleStore:
    """Track request attempts in memory."""

    def __init__(self) -> None:
        """Initialize in-memory request counters and block windows."""
        self._attempts: dict[str, list[float]] = defaultdict(list)
        self._blocked_until: dict[str, float] = {}

    def retry_after(self, key: str, limit: RateLimit) -> int | None:
        """Return seconds until retry when the caller is throttled."""
        now = time()
        blocked_until = self._blocked_until.get(key)
        if blocked_until is not None and blocked_until > now:
            return max(1, int(blocked_until - now))
        if blocked_until is not None:
            self._blocked_until.pop(key, None)
        recent_attempts = [
            attempt
            for attempt in self._attempts.get(key, [])
            if attempt > now - limit.window_seconds
        ]
        self._attempts[key] = recent_attempts
        if len(recent_attempts) >= limit.attempts:
            self._blocked_until[key] = now + limit.block_seconds
            return limit.block_seconds
        return None

    def record_attempt(self, key: str, limit: RateLimit) -> None:
        """Record a new attempt for the given throttle key."""
        now = time()
        recent_attempts = [
            attempt
            for attempt in self._attempts.get(key, [])
            if attempt > now - limit.window_seconds
        ]
        recent_attempts.append(now)
        self._attempts[key] = recent_attempts


class User(Base):  # type: ignore[misc,valid-type]
    """Simple user model backing the starter auth flows."""

    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True)
    username: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    created_at: Mapped[object] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
    )


def database_url_connect_args(database_url: str) -> dict[str, bool]:
    """Return engine connect args for the configured database URL."""
    if database_url.startswith("sqlite"):
        return {"check_same_thread": False}
    return {}


def create_database_engine(database_url: str) -> Engine:
    """Create the SQLAlchemy engine for the application."""
    if database_url.startswith("sqlite:///"):
        database_path = Path(database_url.removeprefix("sqlite:///"))
        database_path.parent.mkdir(parents=True, exist_ok=True)
    return create_engine(
        database_url,
        connect_args=database_url_connect_args(database_url),
        future=True,
    )


def create_session_factory(database_url: str) -> sessionmaker[Session]:
    """Create the SQLAlchemy session factory for the application."""
    return sessionmaker(
        autocommit=False,
        autoflush=False,
        bind=create_database_engine(database_url),
        class_=Session,
    )


def split_csv_env(name: str, default: str) -> list[str]:
    """Split a comma-separated environment variable into trimmed values."""
    return [
        item.strip() for item in os.getenv(name, default).split(",") if item.strip()
    ]


class Settings:
    """Runtime configuration for the FastAPI starter."""

    allowed_hosts: list[str]
    app_name: str
    database_url: str
    debug: bool
    secret_key: str
    support_email: str

    def __init__(  # noqa: PLR0913
        self,
        *,
        allowed_hosts: list[str] | None = None,
        app_name: str | None = None,
        database_url: str | None = None,
        debug: bool | None = None,
        secret_key: str | None = None,
        support_email: str | None = None,
    ) -> None:
        """Resolve runtime settings from explicit values or environment variables."""
        self.allowed_hosts = allowed_hosts or split_csv_env(
            "ALLOWED_HOSTS",
            "127.0.0.1,localhost,[::1],testserver",
        )
        self.app_name = app_name or str(
            os.getenv("APP_NAME", "FastAPI Postgres Starter"),
        )
        self.database_url = database_url or str(
            os.getenv(
                "DATABASE_URL",
                "sqlite:///"
                f"{PACKAGE_ROOT / 'tmp' / 'fastapi_postgres_template.sqlite3'}",
            ),
        )
        self.debug = debug if debug is not None else os.getenv("DEBUG", "0") == "1"
        self.secret_key = secret_key or str(
            os.getenv(
                "SECRET_KEY",
                "",
            ),
        )
        self.support_email = support_email or str(
            os.getenv(
                "SUPPORT_EMAIL",
                "support@example.com",
            ),
        )
        if not self.secret_key:
            msg = "SECRET_KEY must be set."
            raise RuntimeError(msg)


def client_identifier(request: Request) -> str:
    """Resolve the best available client identifier for throttling."""
    if request.client is None:
        return "unknown"
    remote_addr = str(request.client.host)
    if remote_addr not in {"127.0.0.1", "::1"}:
        return remote_addr
    forwarded_for = str(request.headers.get("x-forwarded-for", ""))
    if forwarded_for:
        return forwarded_for.split(",", maxsplit=1)[0].strip()
    real_ip = str(request.headers.get("x-real-ip", "")).strip()
    if real_ip:
        return real_ip
    return remote_addr


def flash_message(request: Request, level: str, text: str) -> None:
    """Store a flash message in the session."""
    flashes = list(request.session.get("flashes", []))
    flashes.append({"level": level, "text": text})
    request.session["flashes"] = flashes


def pop_flashes(request: Request) -> list[dict[str, str]]:
    """Return and clear flash messages from the session."""
    flashes = list(request.session.get("flashes", []))
    request.session["flashes"] = []
    return flashes


def ensure_csrf_token(request: Request) -> str:
    """Ensure the session contains a CSRF token and return it."""
    token = request.session.get("csrf_token")
    if token is None:
        token = secrets.token_urlsafe(32)
        request.session["csrf_token"] = token
    return str(token)


def render_template(
    request: Request,
    template_name: str,
    context: dict[str, Any],
    *,
    status_code: int = 200,
) -> HTMLResponse:
    """Render a Jinja template with shared context."""
    base_context = {
        "app_name": request.app.state.settings.app_name,
        "csrf_token": ensure_csrf_token(request),
        "flashes": pop_flashes(request),
        "request": request,
        "support_email": request.app.state.settings.support_email,
    }
    return TEMPLATES.TemplateResponse(
        request,
        template_name,
        {**base_context, **context},
        status_code=status_code,
    )


def csrf_error_response(request: Request) -> HTMLResponse:
    """Return a conventional CSRF error response."""
    return render_template(
        request,
        "auth/login.html",
        {
            "form_data": {},
            "form_errors": {"__all__": ["The form session expired. Try again."]},
        },
        status_code=400,
    )


def require_authenticated_user(
    request: Request,
    session_factory: sessionmaker[Session],
) -> User | None:
    """Load the authenticated user from the session when present."""
    user_id = request.session.get("user_id")
    if user_id is None:
        return None
    with session_factory() as session:
        return cast("User | None", session.get(User, int(user_id)))


def redirect(
    url: str,
    status_code: int = status.HTTP_303_SEE_OTHER,
) -> RedirectResponse:
    """Build a redirect response."""
    return RedirectResponse(url=url, status_code=status_code)


def send_welcome_email(email: str, username: str) -> None:
    """Emit a simple welcome email for local development."""


def validate_registration(
    session: Session,
    username: str,
    email: str,
    password: str,
    password_confirmation: str,
) -> dict[str, list[str]]:
    """Validate registration form data."""
    errors: dict[str, list[str]] = {}
    normalized_email = email.strip().lower()
    normalized_username = username.strip()
    if not normalized_username or " " in normalized_username:
        errors.setdefault("username", []).append(
            "Enter a valid username without spaces.",
        )
    if "@" not in normalized_email:
        errors.setdefault("email", []).append("Enter a valid email address.")
    if len(password) < MIN_PASSWORD_LENGTH:
        errors.setdefault("password", []).append(
            "This password is too short. It must contain at least 8 characters.",
        )
    if password != password_confirmation:
        errors.setdefault("password_confirmation", []).append(
            "The two password fields did not match.",
        )
    if (
        session.scalar(select(User).where(User.username == normalized_username))
        is not None
    ):
        errors.setdefault("username", []).append("This value is already taken.")
    if session.scalar(select(User).where(User.email == normalized_email)) is not None:
        errors.setdefault("email", []).append("This value is already taken.")
    return errors


def create_app(settings: Settings | None = None) -> FastAPI:  # noqa: C901, PLR0915
    """Create the FastAPI application."""
    runtime_settings = settings or Settings()
    app = FastAPI(debug=runtime_settings.debug)
    app.add_middleware(SessionMiddleware, secret_key=runtime_settings.secret_key)
    app.mount(
        "/static",
        StaticFiles(directory=str(PRM_ROOT / "static")),
        name="static",
    )
    app.state.settings = runtime_settings
    app.state.session_factory = create_session_factory(runtime_settings.database_url)
    app.state.engine = create_database_engine(runtime_settings.database_url)
    app.state.throttle = ThrottleStore()
    Base.metadata.create_all(bind=app.state.engine)
    login_rate_limit = RateLimit(*LOGIN_RATE_LIMIT)
    signup_rate_limit = RateLimit(*SIGNUP_RATE_LIMIT)

    @app.get("/", response_class=HTMLResponse)  # type: ignore[untyped-decorator]
    def home(request: Request) -> HTMLResponse:
        user = require_authenticated_user(request, app.state.session_factory)
        return render_template(request, "home.html", {"user_summary": user})

    @app.get("/register", response_class=HTMLResponse)  # type: ignore[untyped-decorator]
    def register_page(request: Request) -> HTMLResponse:
        if require_authenticated_user(request, app.state.session_factory) is not None:
            return redirect("/app")
        return render_template(
            request,
            "auth/register.html",
            {"form_data": {}, "form_errors": {}},
        )

    @app.post(  # type: ignore[untyped-decorator]
        "/register",
        response_class=HTMLResponse,
        response_model=None,
    )
    def register_submit(  # noqa: PLR0913
        request: Request,
        username: Annotated[str, Form()],
        email: Annotated[str, Form()],
        password: Annotated[str, Form()],
        password_confirmation: Annotated[str, Form()],
        csrf_token: Annotated[str, Form()],
    ) -> HTMLResponse | RedirectResponse:
        if csrf_token != request.session.get("csrf_token"):
            return csrf_error_response(request)
        throttle_key = f"signup:{client_identifier(request)}"
        retry_after = app.state.throttle.retry_after(throttle_key, signup_rate_limit)
        if retry_after is not None:
            return render_template(
                request,
                "auth/register.html",
                {
                    "form_data": {"username": username, "email": email},
                    "form_errors": {
                        "__all__": [
                            "Too many signup attempts. "
                            f"Try again in about {retry_after} seconds.",
                        ],
                    },
                },
                status_code=429,
            )
        app.state.throttle.record_attempt(throttle_key, signup_rate_limit)
        with app.state.session_factory() as session:
            errors = validate_registration(
                session,
                username,
                email,
                password,
                password_confirmation,
            )
            if errors:
                return render_template(
                    request,
                    "auth/register.html",
                    {
                        "form_data": {"username": username, "email": email},
                        "form_errors": errors,
                    },
                )
            user = User(
                email=email.strip().lower(),
                password_hash=generate_password_hash(password),
                username=username.strip(),
            )
            session.add(user)
            session.commit()
            session.refresh(user)
        send_welcome_email(user.email, user.username)
        request.session["user_id"] = user.id
        flash_message(
            request,
            "success",
            f"Welcome, {user.username}. Your account is ready.",
        )
        return redirect("/app")

    @app.get("/login", response_class=HTMLResponse)  # type: ignore[untyped-decorator]
    def login_page(request: Request) -> HTMLResponse:
        if require_authenticated_user(request, app.state.session_factory) is not None:
            return redirect("/app")
        return render_template(
            request,
            "auth/login.html",
            {"form_data": {}, "form_errors": {}},
        )

    @app.post(  # type: ignore[untyped-decorator]
        "/login",
        response_class=HTMLResponse,
        response_model=None,
    )
    def login_submit(
        request: Request,
        login: Annotated[str, Form()],
        password: Annotated[str, Form()],
        csrf_token: Annotated[str, Form()],
    ) -> HTMLResponse | RedirectResponse:
        if csrf_token != request.session.get("csrf_token"):
            return csrf_error_response(request)
        throttle_key = f"login:{client_identifier(request)}"
        retry_after = app.state.throttle.retry_after(throttle_key, login_rate_limit)
        if retry_after is not None:
            return render_template(
                request,
                "auth/login.html",
                {
                    "form_data": {"login": login},
                    "form_errors": {
                        "__all__": [
                            "Too many login attempts. "
                            f"Try again in about {retry_after} seconds.",
                        ],
                    },
                },
                status_code=429,
            )
        app.state.throttle.record_attempt(throttle_key, login_rate_limit)
        with app.state.session_factory() as session:
            user = session.scalar(
                select(User).where(
                    (User.email == login.strip().lower())
                    | (User.username == login.strip()),
                ),
            )
            if user is None or not check_password_hash(user.password_hash, password):
                return render_template(
                    request,
                    "auth/login.html",
                    {
                        "form_data": {"login": login},
                        "form_errors": {
                            "__all__": ["The credentials you entered are invalid."],
                        },
                    },
                )
        request.session["user_id"] = user.id
        flash_message(request, "success", f"Welcome back, {user.username}.")
        return redirect("/app")

    @app.get(  # type: ignore[untyped-decorator]
        "/app",
        response_class=HTMLResponse,
        response_model=None,
    )
    def dashboard(request: Request) -> HTMLResponse | RedirectResponse:
        user = require_authenticated_user(request, app.state.session_factory)
        if user is None:
            return redirect("/login")
        return render_template(request, "dashboard.html", {"user_summary": user})

    @app.post("/logout", response_model=None)  # type: ignore[untyped-decorator]
    def logout(
        request: Request,
        csrf_token: Annotated[str, Form()],
    ) -> RedirectResponse | HTMLResponse:
        if csrf_token != request.session.get("csrf_token"):
            return csrf_error_response(request)
        request.session.clear()
        flash_message(request, "success", "You have been signed out.")
        return redirect("/")

    @app.post("/account/delete", response_model=None)  # type: ignore[untyped-decorator]
    def delete_account(
        request: Request,
        csrf_token: Annotated[str, Form()],
    ) -> RedirectResponse | HTMLResponse:
        if csrf_token != request.session.get("csrf_token"):
            return csrf_error_response(request)
        user = require_authenticated_user(request, app.state.session_factory)
        if user is None:
            return redirect("/login")
        username = user.username
        with app.state.session_factory() as session:
            stored_user = session.get(User, user.id)
            if stored_user is not None:
                session.delete(stored_user)
                session.commit()
        request.session.clear()
        flash_message(
            request,
            "success",
            f"The {username} account has been deleted.",
        )
        return redirect("/")

    @app.get("/health")  # type: ignore[untyped-decorator]
    def health() -> JSONResponse:
        database_error = None
        try:
            with app.state.engine.connect() as connection:
                connection.execute(text("SELECT 1"))
        except SQLAlchemyError as exc:  # pragma: no cover
            database_error = str(exc)
        memory_rss_mb = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024
        memory_healthy = memory_rss_mb <= MEMORY_FAIL_THRESHOLD_MB
        database_healthy = database_error is None
        is_healthy = database_healthy and memory_healthy
        return JSONResponse(
            {
                "checks": {
                    "database": {
                        "error": database_error,
                        "healthy": database_healthy,
                    },
                    "memory": {
                        "failThresholdMb": MEMORY_FAIL_THRESHOLD_MB,
                        "healthy": memory_healthy,
                        "rssMb": round(memory_rss_mb, 2),
                        "warnThresholdMb": MEMORY_WARN_THRESHOLD_MB,
                    },
                },
                "isHealthy": is_healthy,
            },
            status_code=200 if is_healthy else 503,
        )

    @app.exception_handler(404)  # type: ignore[untyped-decorator]
    def not_found_handler(request: Request, _exc: Exception) -> HTMLResponse:
        return render_template(request, "404.html", {}, status_code=404)

    return app


app = create_app()


def build_test_client(_database_name: str) -> TestClient:
    """Create a test client backed by the configured PostgreSQL database."""
    app = create_app(
        Settings(
            allowed_hosts=["127.0.0.1", "localhost", "testserver"],
            database_url=os.environ["DATABASE_URL"],
            secret_key=TEST_SECRET_KEY,
        ),
    )
    return TestClient(app)


def csrf_token(response_text: str) -> str:
    """Extract the CSRF token from an HTML form."""
    marker = 'name="csrf_token" type="hidden" value="'
    start = response_text.find(marker)
    if start == -1:
        raise AssertionError
    value_start = start + len(marker)
    value_end = response_text.find('"', value_start)
    if value_end == -1:
        raise AssertionError
    return response_text[value_start:value_end]


class _TestCase(unittest.TestCase):
    def setUp(self) -> None:
        """Create a fresh client and database for each test."""
        self.client = build_test_client(self.id().split(".")[-1])
        Base.metadata.drop_all(bind=self.client.app.state.engine)
        Base.metadata.create_all(bind=self.client.app.state.engine)

    def tearDown(self) -> None:
        """Close client resources after each test case."""
        self.client.close()
        self.client.app.state.engine.dispose()

    def test_home_page_shows_the_starter_surface(self) -> None:
        """Render the landing page for anonymous visitors."""
        response = self.client.get("/")
        self.assertEqual(response.status_code, HTTP_OK)  # noqa: PT009
        self.assertIn("Build the app, not the scaffold.", response.text)  # noqa: PT009
        self.assertIn("Postgres", response.text)  # noqa: PT009

    def test_registration_login_logout_and_account_deletion_work(self) -> None:
        """Exercise the full account lifecycle."""
        register_page = self.client.get("/register")
        registration = self.client.post(
            "/register",
            data={
                "csrf_token": csrf_token(register_page.text),
                "email": "starter@example.com",
                "password": "password123",
                "password_confirmation": "password123",
                "username": "starter-user",
            },
            follow_redirects=True,
        )
        self.assertEqual(registration.status_code, HTTP_OK)  # noqa: PT009
        self.assertIn("starter-user", registration.text)  # noqa: PT009
        logout_page = self.client.get("/app")
        logout_response = self.client.post(
            "/logout",
            data={"csrf_token": csrf_token(logout_page.text)},
            follow_redirects=True,
        )
        self.assertIn("signed out", logout_response.text)  # noqa: PT009
        login_page = self.client.get("/login")
        login_response = self.client.post(
            "/login",
            data={
                "csrf_token": csrf_token(login_page.text),
                "login": "starter@example.com",
                "password": "password123",
            },
            follow_redirects=True,
        )
        self.assertIn("Welcome back, starter-user.", login_response.text)  # noqa: PT009
        delete_page = self.client.get("/app")
        delete_response = self.client.post(
            "/account/delete",
            data={"csrf_token": csrf_token(delete_page.text)},
            follow_redirects=True,
        )
        self.assertIn("account has been deleted", delete_response.text)  # noqa: PT009

    def test_login_accepts_username_as_well_as_email(self) -> None:
        """Support username-based login in addition to email."""
        register_page = self.client.get("/register")
        self.client.post(
            "/register",
            data={
                "csrf_token": csrf_token(register_page.text),
                "email": "username-login@example.com",
                "password": "password123",
                "password_confirmation": "password123",
                "username": "username-login",
            },
        )
        logout_page = self.client.get("/app")
        logout_response = self.client.post(
            "/logout",
            data={"csrf_token": csrf_token(logout_page.text)},
            follow_redirects=False,
        )
        self.assertEqual(logout_response.status_code, HTTP_SEE_OTHER)  # noqa: PT009
        login_page = self.client.get("/login")
        response = self.client.post(
            "/login",
            data={
                "csrf_token": csrf_token(login_page.text),
                "login": "username-login",
                "password": "password123",
            },
            follow_redirects=True,
        )
        self.assertIn("Welcome back, username-login.", response.text)  # noqa: PT009

    def test_registration_validation_errors_are_shown(self) -> None:
        """Render validation feedback for invalid signup submissions."""
        register_page = self.client.get("/register")
        response = self.client.post(
            "/register",
            data={
                "csrf_token": csrf_token(register_page.text),
                "email": "invalid-email",
                "password": "short",
                "password_confirmation": "different",
                "username": "bad username",
            },
        )
        self.assertEqual(response.status_code, HTTP_OK)  # noqa: PT009
        self.assertIn("at least 8 characters", response.text)  # noqa: PT009

    def test_invalid_login_keeps_the_visitor_on_the_login_form(self) -> None:
        """Keep the visitor on the login form after invalid credentials."""
        login_page = self.client.get("/login")
        response = self.client.post(
            "/login",
            data={
                "csrf_token": csrf_token(login_page.text),
                "login": "missing@example.com",
                "password": "password123",
            },
        )
        self.assertEqual(response.status_code, HTTP_OK)  # noqa: PT009
        self.assertIn("credentials you entered are invalid", response.text)  # noqa: PT009

    def test_signup_is_rate_limited(self) -> None:
        """Throttle repeated signup attempts from the same client."""
        for _ in range(3):
            register_page = self.client.get("/register")
            response = self.client.post(
                "/register",
                data={
                    "csrf_token": csrf_token(register_page.text),
                    "email": "invalid-email",
                    "password": "short",
                    "password_confirmation": "different",
                    "username": "bad username",
                },
            )
            self.assertEqual(response.status_code, HTTP_OK)  # noqa: PT009
        blocked_page = self.client.get("/register")
        blocked_response = self.client.post(
            "/register",
            data={
                "csrf_token": csrf_token(blocked_page.text),
                "email": "invalid-email",
                "password": "short",
                "password_confirmation": "different",
                "username": "bad username",
            },
        )
        self.assertEqual(blocked_response.status_code, HTTP_TOO_MANY_REQUESTS)  # noqa: PT009

    def test_login_is_rate_limited(self) -> None:
        """Throttle repeated login attempts from the same client."""
        for _ in range(5):
            login_page = self.client.get("/login")
            response = self.client.post(
                "/login",
                data={
                    "csrf_token": csrf_token(login_page.text),
                    "login": "missing@example.com",
                    "password": "password123",
                },
            )
            self.assertEqual(response.status_code, HTTP_OK)  # noqa: PT009
        blocked_page = self.client.get("/login")
        blocked_response = self.client.post(
            "/login",
            data={
                "csrf_token": csrf_token(blocked_page.text),
                "login": "missing@example.com",
                "password": "password123",
            },
        )
        self.assertEqual(blocked_response.status_code, HTTP_TOO_MANY_REQUESTS)  # noqa: PT009

    def test_authenticated_visitors_see_their_current_session_summary_on_the_home_page(
        self,
    ) -> None:
        """Show current-session details on the landing page for signed-in users."""
        register_page = self.client.get("/register")
        self.client.post(
            "/register",
            data={
                "csrf_token": csrf_token(register_page.text),
                "email": "home@example.com",
                "password": "password123",
                "password_confirmation": "password123",
                "username": "home-user",
            },
        )
        response = self.client.get("/")
        self.assertIn("Current session", response.text)  # noqa: PT009
        self.assertIn("home-user", response.text)  # noqa: PT009

    def test_not_found_page_returns_a_conventional_404(self) -> None:
        """Render the custom not-found page for unknown routes."""
        response = self.client.get("/missing")
        self.assertEqual(response.status_code, HTTP_NOT_FOUND)  # noqa: PT009
        self.assertIn("Page Not Found", response.text)  # noqa: PT009


def main() -> None:
    """Run the application or the embedded test suite."""
    if os.getenv("DEBUG"):
        test_program = unittest.main(exit=False)
        app.state.engine.dispose()
        raise SystemExit(0 if test_program.result.wasSuccessful() else 1)
    uvicorn.run(
        app,
        host=os.getenv("HOST", "127.0.0.1"),
        port=int(os.getenv("PORT", "8000")),
    )


if __name__ == "__main__":
    main()
