from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import CustomUser, Swipe, ChatRoom, ChatMessage
from .serializers import UserSerializer, SwipeSerializer, ChatMessageSerializer, UserUpdateSerializer
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
    
class UserUpdateView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def put(self, request):
        user = request.user
        data = request.data.copy()
        if 'profile_picture' in request.FILES:
            data['profile_picture'] = request.FILES['profile_picture']
        
        serializer = UserUpdateSerializer(user, data=data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=400)



# Thích hoặc không thích một người
class SwipeView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request):
        data = request.data
        data['liker'] = request.user.id
        serializer = SwipeSerializer(data=data)
        if serializer.is_valid():
            swipe = serializer.save()

            # Kiểm tra nếu hai người dùng thích nhau
            match = Swipe.objects.filter(
                liker=swipe.liked,
                liked=swipe.liker,
                is_like=True
            ).first()

            if match:
                # Đánh dấu cả hai swipe là match
                match.is_match = True
                match.save()
                swipe.is_match = True
                swipe.save()

                # Tạo phòng chat hoặc lấy phòng chat hiện tại
                chat_room, created = ChatRoom.objects.get_or_create(
                    id=min(swipe.liker.id, swipe.liked.id) * 1000 + max(swipe.liker.id, swipe.liked.id),  # Đảm bảo ID phòng duy nhất
                )
                if created:
                    chat_room.users.set([request.user, swipe.liked])  # Thêm người dùng vào phòng


                return Response({
                    "match": True,
                    "message": "It's a match!",
                    "chat_room_id": chat_room.id
                })

            return Response({"match": False, "message": "Swipe saved."})
        return Response(serializer.errors, status=400)

class MatchListView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        matches = Swipe.objects.filter(liker=request.user, is_match=True).select_related('liked')
        match_users = [match.liked for match in matches]

        response_data = []
        for user in match_users:
            chat_room = ChatRoom.objects.filter(users__in=[request.user, user]).distinct().first()
            profile_picture_url = request.build_absolute_uri(user.profile_picture.url) if user.profile_picture else None
            response_data.append({
                "username": user.username,
                "profile_picture": profile_picture_url,
                "room_id": chat_room.id if chat_room else None,
            })

        return Response(response_data)



class CurrentUserProfileView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # Trả về thông tin người dùng hiện tại
        user = request.user
        serializer = UserSerializer(user, context={'request': request})
        return Response(serializer.data)


class ChatMessageListView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request, room_id):
        try:
            room = ChatRoom.objects.get(id=room_id)
        except ChatRoom.DoesNotExist:
            return Response({"error": "Chat room does not exist"}, status=404)

        messages = ChatMessage.objects.filter(room=room).order_by('timestamp')
        serializer = ChatMessageSerializer(messages, many=True)
        return Response(serializer.data)




