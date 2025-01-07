from rest_framework import serializers
from .models import CustomUser, Swipe, ChatMessage

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id','first_name', 'last_name', 'username', 'email', 'password', 'bio', 'location', 'gender', 'profile_picture', 'age']
        extra_kwargs = {
            'password': {'write_only': True}  # Đảm bảo mật khẩu chỉ ghi, không trả về
        }

    def create(self, validated_data):
        # Sử dụng set_password để hash mật khẩu
        password = validated_data.pop('password', None)
        instance = self.Meta.model(**validated_data)
        if password:
            instance.set_password(password)
        instance.save()
        return instance
    

    def get_profile_picture(self, obj):
        request = self.context.get('request')
        if obj.profile_picture:
            # Đảm bảo đường dẫn luôn đúng
            if not obj.profile_picture.url.startswith('/'):
                return request.build_absolute_uri('/' + obj.profile_picture.url)
            return request.build_absolute_uri(obj.profile_picture.url)
        return None


class UserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['username', 'bio', 'location', 'gender', 'profile_picture', 'age']


class SwipeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Swipe
        fields = '__all__'

class ChatMessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatMessage
        fields = '__all__'
