"""Application routes for the Django starter."""

from django.urls import path

from . import views

urlpatterns = [
    path("", views.home, name="home"),
    path("register", views.register_view, name="register"),
    path("login", views.login_view, name="login"),
    path("logout", views.logout_view, name="logout"),
    path("account/delete", views.delete_account_view, name="account-delete"),
    path("app", views.dashboard, name="dashboard"),
    path("health", views.health, name="health"),
]
