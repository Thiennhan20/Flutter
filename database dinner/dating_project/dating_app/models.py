from django.contrib.auth.models import AbstractUser
from django.db import models

class CustomUser(AbstractUser):
    bio = models.TextField(null=True, blank=True)
    location = models.CharField(max_length=100, null=True, blank=True)
    gender = models.CharField(max_length=10, choices=[('male', 'Male'), ('female', 'Female')])
    profile_picture = models.ImageField(upload_to='profile_pictures/', null=True, blank=True)


# Hồ sơ người dùng
class Profile(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
    interested_in = models.CharField(max_length=10, choices=[('male', 'Male'), ('female', 'Female'), ('both', 'Both')])

# Thích và không thích
class Swipe(models.Model):
    liker = models.ForeignKey(CustomUser, related_name='liker', on_delete=models.CASCADE)
    liked = models.ForeignKey(CustomUser, related_name='liked', on_delete=models.CASCADE)
    liked_at = models.DateTimeField(auto_now_add=True)
    is_like = models.BooleanField()  # True nếu thích, False nếu không thích

# Tin nhắn
class Message(models.Model):
    sender = models.ForeignKey(CustomUser, related_name='sent_messages', on_delete=models.CASCADE)
    receiver = models.ForeignKey(CustomUser, related_name='received_messages', on_delete=models.CASCADE)
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
