"""Views for the Django starter application."""

import resource

from django.contrib import messages
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.core.mail import send_mail
from django.db import DatabaseError, connection
from django.http import HttpRequest, HttpResponse, HttpResponseRedirect, JsonResponse
from django.shortcuts import redirect, render
from django.views.decorators.http import require_GET, require_http_methods, require_POST

from .forms import LoginForm, RegistrationForm
from .throttle import LOGIN_RATE_LIMIT, SIGNUP_RATE_LIMIT, throttle_submission

MEMORY_WARN_THRESHOLD_MB = 400
MEMORY_FAIL_THRESHOLD_MB = 600


def client_identifier(request: HttpRequest) -> str:
    """Resolve the best available client identifier for throttling."""
    remote_addr = str(request.META.get("REMOTE_ADDR", "unknown"))
    if remote_addr not in {"127.0.0.1", "::1"}:
        return remote_addr
    forwarded_for = str(request.META.get("HTTP_X_FORWARDED_FOR", ""))
    if forwarded_for:
        return forwarded_for.split(",", maxsplit=1)[0].strip()
    real_ip = str(request.META.get("HTTP_X_REAL_IP", "")).strip()
    if real_ip:
        return real_ip
    return remote_addr


@require_GET  # type: ignore[untyped-decorator]
def home(request: HttpRequest) -> HttpResponse:
    """Render the landing page."""
    return render(
        request,
        "home.html",
        {
            "user_summary": request.user if request.user.is_authenticated else None,
        },
    )


@require_http_methods(["GET", "POST"])  # type: ignore[untyped-decorator]
def register_view(request: HttpRequest) -> HttpResponse:
    """Create a user account and sign the user into the session."""
    if request.user.is_authenticated:
        return redirect("dashboard")
    form = RegistrationForm(request.POST or None)
    if request.method == "POST":
        retry_after = throttle_submission(
            "signup",
            client_identifier(request),
            SIGNUP_RATE_LIMIT,
        )
        if retry_after is not None:
            form.add_error(
                None,
                f"Too many signup attempts. Try again in about {retry_after} seconds.",
            )
            return render(request, "auth/register.html", {"form": form}, status=429)
    if request.method == "POST" and form.is_valid():
        user = form.save()
        send_mail(
            subject="Welcome to the Django Starter",
            message=f"Welcome, {user.username}. Your account is ready.",  # type: ignore[attr-defined]
            from_email=None,
            recipient_list=[user.email],  # type: ignore[attr-defined]
        )
        login(request, user, backend="starter.auth_backends.EmailOrUsernameBackend")
        messages.success(
            request,
            f"Welcome, {user.username}. Your account is ready.",  # type: ignore[attr-defined]
        )
        return redirect("dashboard")
    return render(request, "auth/register.html", {"form": form})


@require_http_methods(["GET", "POST"])  # type: ignore[untyped-decorator]
def login_view(request: HttpRequest) -> HttpResponse:
    """Authenticate a user by username or email."""
    if request.user.is_authenticated:
        return redirect("dashboard")
    form = LoginForm(request.POST or None)
    if request.method == "POST":
        retry_after = throttle_submission(
            "login",
            client_identifier(request),
            LOGIN_RATE_LIMIT,
        )
        if retry_after is not None:
            form.add_error(
                None,
                f"Too many login attempts. Try again in about {retry_after} seconds.",
            )
            return render(request, "auth/login.html", {"form": form}, status=429)
    if request.method == "POST" and form.is_valid():
        user = authenticate(
            request,
            login=form.cleaned_data["login"],
            password=form.cleaned_data["password"],
        )
        if user is not None:
            login(request, user, backend="starter.auth_backends.EmailOrUsernameBackend")
            messages.success(
                request,
                f"Welcome back, {user.username}.",
            )
            return redirect("dashboard")
        messages.error(request, "The credentials you entered are invalid.")
    return render(request, "auth/login.html", {"form": form})


@require_POST  # type: ignore[untyped-decorator]
@login_required  # type: ignore[untyped-decorator]
def logout_view(request: HttpRequest) -> HttpResponseRedirect:
    """End the current authenticated session."""
    logout(request)
    messages.success(request, "You have been signed out.")
    return redirect("home")


@require_POST  # type: ignore[untyped-decorator]
@login_required  # type: ignore[untyped-decorator]
def delete_account_view(request: HttpRequest) -> HttpResponseRedirect:
    """Delete the authenticated user's account."""
    user = request.user
    username = user.username
    logout(request)
    user.delete()
    messages.success(request, f"The {username} account has been deleted.")
    return redirect("home")


@require_GET  # type: ignore[untyped-decorator]
@login_required  # type: ignore[untyped-decorator]
def dashboard(request: HttpRequest) -> HttpResponse:
    """Render the authenticated dashboard."""
    return render(request, "dashboard.html", {"user_summary": request.user})


@require_GET  # type: ignore[untyped-decorator]
def health(_request: HttpRequest) -> JsonResponse:
    """Report database and memory health for the application."""
    database_error = None
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
    except DatabaseError as exc:  # pragma: no cover
        database_error = str(exc)
    memory_rss_mb = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024
    memory_healthy = memory_rss_mb <= MEMORY_FAIL_THRESHOLD_MB
    database_healthy = database_error is None
    is_healthy = database_healthy and memory_healthy
    return JsonResponse(
        {
            "isHealthy": is_healthy,
            "checks": {
                "database": {
                    "healthy": database_healthy,
                    "error": database_error,
                },
                "memory": {
                    "healthy": memory_healthy,
                    "rssMb": round(memory_rss_mb, 2),
                    "warnThresholdMb": MEMORY_WARN_THRESHOLD_MB,
                    "failThresholdMb": MEMORY_FAIL_THRESHOLD_MB,
                },
            },
        },
        status=200 if is_healthy else 503,
    )
