# ruff: noqa: D100, D103, ARG001, INP001
from django.http import HttpRequest, HttpResponse


def hello_world(request: HttpRequest) -> HttpResponse:
    return HttpResponse("Hello World!")
