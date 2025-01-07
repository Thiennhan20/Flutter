from django.urls import path
from .views import UserListView, SwipeView, UserCreateView, CurrentUserProfileView, MatchListView, ChatMessageListView, UserUpdateView
from django.conf import settings
from django.conf.urls.static import static
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView


urlpatterns = [
    path('users/', UserListView.as_view(), name='user-list'),
    path('register/', UserCreateView.as_view(), name='user-create'),  # Endpoint tạo người dùng
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('swipe/', SwipeView.as_view(), name='swipe'),
    path('matches/', MatchListView.as_view(), name='matches'),
    path('profile/', CurrentUserProfileView.as_view(), name='current-user-profile'),
    path('chat/<int:room_id>/messages/', ChatMessageListView.as_view(), name='chat-messages'),
    path('update-profile/', UserUpdateView.as_view(), name='update-profile'),
]+ static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
