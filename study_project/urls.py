from django.contrib import admin
from django.http import HttpResponse
from django.urls import path


def home(request):
    return HttpResponse("Hello from Dockerized Django + PostgreSQL + Nginx!")


urlpatterns = [
    path("admin/", admin.site.urls),
    path("", home),
]
