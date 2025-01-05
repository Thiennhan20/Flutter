from rest_framework import serializers
from .models import CustomUser, Profile, Swipe, Message

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'password', 'bio', 'location', 'gender', 'profile_picture']
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
    
    def get_profile(self, obj):
        # Lấy thông tin từ bảng Profile liên kết
        try:
            profile = Profile.objects.get(user=obj)
            return ProfileSerializer(profile).data
        except Profile.DoesNotExist:
            return None

    def get_profile_picture(self, obj):
        request = self.context.get('request')
        if obj.profile_picture:
            return request.build_absolute_uri(obj.profile_picture.url)
        return None

class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = '__all__'

class SwipeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Swipe
        fields = '__all__'

class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = '__all__'
