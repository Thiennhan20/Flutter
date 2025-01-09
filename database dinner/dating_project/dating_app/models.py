from django.contrib.auth.models import AbstractUser
from django.db import models

class CustomUser(AbstractUser):
    bio = models.TextField(null=True, blank=True)
    location = models.CharField(max_length=100, null=True, blank=True)
    gender = models.CharField(max_length=10, choices=[('male', 'Male'), ('female', 'Female')])
    profile_picture = models.ImageField(upload_to='profile_pictures/', null=True, blank=True)
    age = models.IntegerField(null=True, blank=True)

# Thích và không thích
class Swipe(models.Model):
    liker = models.ForeignKey(CustomUser, related_name='liker', on_delete=models.CASCADE)
    liked = models.ForeignKey(CustomUser, related_name='liked', on_delete=models.CASCADE)
    liked_at = models.DateTimeField(auto_now_add=True)
    is_like = models.BooleanField()  # True nếu thích, False nếu không thích
    is_match = models.BooleanField(default=False)  # Đánh dấu nếu là match


# Tin nhắn
class ChatRoom(models.Model):
    id = models.CharField(max_length=255, primary_key=True)
    users = models.ManyToManyField(CustomUser, related_name="chat_rooms")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"ChatRoom {self.id}"

class ChatMessage(models.Model):
    room = models.ForeignKey(ChatRoom, on_delete=models.CASCADE, related_name="messages")
    sender = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    message = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
