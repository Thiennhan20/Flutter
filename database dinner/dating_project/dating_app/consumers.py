from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from .models import ChatMessage, ChatRoom
import json

class ChatRoomConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_name = self.scope['url_route']['kwargs']['room_name']
        self.room_group_name = f'chat_{self.room_name}'

        try:
            # Kiểm tra xác thực
            if not self.scope["user"] or not self.scope["user"].is_authenticated:
                raise Exception("User not authenticated.")

            # Lấy thông tin phòng chat
            self.room = await self.get_room(self.room_name)

            # Thêm client vào nhóm chat
            await self.channel_layer.group_add(
                self.room_group_name,
                self.channel_name,
            )
            await self.accept()
            print(f"WebSocket connected to room: {self.room_name}")
        except Exception as e:
            print(f"Error during WebSocket connection: {e}")
            await self.close()


    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name,
        )

    async def receive(self, text_data):
        data = json.loads(text_data)
        message = data['message']
        username = self.scope['user'].username

        # Lưu tin nhắn vào cơ sở dữ liệu
        await self.save_message(self.room, self.scope['user'], message)

        # Gửi tin nhắn tới nhóm chat với metadata
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': message,
                'username': username,
                'sender': self.scope['user'].id,  # ID người gửi
            }
        )

    async def chat_message(self, event):
        # Gửi tin nhắn tới các client khác (không bao gồm người gửi)
        if event['sender'] != self.scope['user'].id:  # Loại trừ chính người gửi
            await self.send(text_data=json.dumps({
                'username': event['username'],
                'message': event['message'],
                'sender': event['sender'],
            }))


    @database_sync_to_async
    def get_room(self, room_name):
        try:
            room = ChatRoom.objects.get(id=room_name)
            print(f"Room found: {room_name}")
            return room
        except ChatRoom.DoesNotExist:
            print(f"Room not found: {room_name}")
            raise Exception(f"Room with id {room_name} does not exist.")


    @database_sync_to_async
    def save_message(self, room, user, message):
        ChatMessage.objects.create(
            room=room,
            sender=user,
            message=message,
        )
