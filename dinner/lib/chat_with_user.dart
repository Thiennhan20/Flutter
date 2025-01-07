import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';



class ChatWithUserScreen extends StatefulWidget {
  final String token;
  final int? roomId; // The Chat Room ID
  final String username; // Matched user's username
  final String profilePicture; // Matched user's profile picture

  const ChatWithUserScreen({
    Key? key,
    required this.token,
    required this.roomId,
    required this.username,
    required this.profilePicture,
  }) : super(key: key);

  @override
  _ChatWithUserScreenState createState() => _ChatWithUserScreenState();
}

class _ChatWithUserScreenState extends State<ChatWithUserScreen> {
  late WebSocketChannel channel;
  List<Map<String, String>> messages = []; // Stores chat messages
  final TextEditingController messageController = TextEditingController();
  bool showEmojiPicker = false; // Hiển thị bàn phím emoji hay không

  void onEmojiSelected(Emoji emoji) {
    messageController.text += emoji.emoji; // Thêm emoji vào ô nhập
  }
  @override
  void initState() {
    super.initState();
    if (widget.roomId == null) {
      // Hiển thị lỗi và quay lại
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid Room ID!")),
        );
        Navigator.pop(context);
      });
    }
    channel = WebSocketChannel.connect(
      Uri.parse('ws://10.147.18.78:8000/ws/chat/${widget.roomId}/?token=${widget.token}'),
    );


    // Listen for incoming messages
    channel.stream.listen((data) {
      print("Received data: $data");
      final decodedMessage = json.decode(data);

      // Bỏ qua tin nhắn nếu là của chính người gửi
      if (decodedMessage['sender'] != widget.token) {
        setState(() {
          messages.add({
            'sender': decodedMessage['username'],
            'message': decodedMessage['message'],
          });
        });
      }
    });


  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      final message = messageController.text.trim();
      print("Sending message: $message");

      channel.sink.add(
        json.encode({
          'message': message,
          'username': widget.username,  // Tên người dùng
          'sender': widget.token,       // Token (ID người gửi)
        }),
      );

      setState(() {
        messages.add({
          'sender': 'You',
          'message': message,
        });
      });

      messageController.clear();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.profilePicture),
            ),
            const SizedBox(width: 10),
            Text(
              widget.username,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {
              // Video call functionality (if needed)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - index - 1];
                final isMe = message['sender'] == 'You';
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[800],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      message['message']!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          // Message input field
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
