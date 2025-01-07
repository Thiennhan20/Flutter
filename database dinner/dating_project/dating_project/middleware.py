from channels.middleware import BaseMiddleware
from jwt import decode as jwt_decode
from django.conf import settings
from django.contrib.auth import get_user_model
from channels.db import database_sync_to_async
from urllib.parse import parse_qs

CustomUser = get_user_model()

@database_sync_to_async
def get_user(user_id):
    try:
        return CustomUser.objects.get(id=user_id)
    except CustomUser.DoesNotExist:
        return None

class JWTAuthMiddleware(BaseMiddleware):
    async def __call__(self, scope, receive, send):
        # Lấy token từ query string
        query_string = scope.get('query_string', b'').decode()
        query_params = parse_qs(query_string)
        token = query_params.get('token', [None])[0]

        if token:
            try:
                payload = jwt_decode(token, settings.SECRET_KEY, algorithms=["HS256"])
                scope['user'] = await get_user(payload.get('user_id'))
            except Exception as e:
                print(f"JWT Error: {e}")
                scope['user'] = None
        else:
            scope['user'] = None

        return await super().__call__(scope, receive, send)