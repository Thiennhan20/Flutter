from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import CustomUser, Profile, Swipe, Message
from .serializers import UserSerializer, ProfileSerializer, SwipeSerializer, MessageSerializer
from rest_framework_simplejwt.authentication import JWTAuthentication


# Lấy danh sách người dùng (tìm người để ghép đôi)
class UserListView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        print("Current user:", request.user)  # Kiểm tra thông tin người dùng hiện tại
        # Loại bỏ tài khoản admin và bản thân người dùng hiện tại
        users = CustomUser.objects.exclude(id=request.user.id).exclude(is_superuser=True)
        serializer = UserSerializer(users, many=True, context={'request': request})
        return Response(serializer.data)

    
# API thêm người dùng mới
class UserCreateView(APIView):
    permission_classes = []  # Tùy chỉnh quyền truy cập nếu cần

    def post(self, request):
        # Nhận dữ liệu từ request
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)  # Trả về dữ liệu người dùng mới tạo
        return Response(serializer.errors, status=400)  # Trả về lỗi nếu không hợp lệ


# Thích hoặc không thích một người
class SwipeView(APIView):
    permission_classes = []

    def post(self, request):
        data = request.data
        data['liker'] = request.user.id
        serializer = SwipeSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=400)

class CurrentUserProfileView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # Trả về thông tin người dùng hiện tại
        user = request.user
        serializer = UserSerializer(user, context={'request': request})
        return Response(serializer.data)


# Lấy danh sách tin nhắn
class MessageListView(APIView):
    permission_classes = []

    def get(self, request):
        messages = Message.objects.filter(receiver=request.user)
        serializer = MessageSerializer(messages, many=True)
        return Response(serializer.data)

    def post(self, request):
        data = request.data
        data['sender'] = request.user.id
        serializer = MessageSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=400)


