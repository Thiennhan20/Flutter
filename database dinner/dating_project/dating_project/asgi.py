"""
ASGI config for dating_project project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.1/howto/deployment/asgi/
"""

import os
import django
from django.core.exceptions import ImproperlyConfigured

try:
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dating_project.settings')
    django.setup()
except ImproperlyConfigured as e:
    print("Django configuration error:", e)

from channels.routing import ProtocolTypeRouter, URLRouter
from dating_project.middleware import JWTAuthMiddleware
from channels.sessions import SessionMiddlewareStack
import dating_app.routing
from django.core.asgi import get_asgi_application


application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": JWTAuthMiddleware(
        URLRouter(
            dating_app.routing.websocket_urlpatterns
        )
    ),
})

