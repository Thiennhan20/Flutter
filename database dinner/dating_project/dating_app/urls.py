from django.urls import path
from .views import UserListView, SwipeView, MessageListView, UserCreateView, CurrentUserProfileView
from django.conf import settings
from django.conf.urls.static import static
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView


urlpatterns = [
    path('users/', UserListView.as_view(), name='user-list'),
    path('register/', UserCreateView.as_view(), name='user-create'),  # Endpoint tạo người dùng
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('swipe/', SwipeView.as_view(), name='swipe'),
    path('profile/', CurrentUserProfileView.as_view(), name='current-user-profile'),
    path('messages/', MessageListView.as_view(), name='message-list'),
]+ static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
