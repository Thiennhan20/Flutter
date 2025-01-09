import 'dart:convert';
import 'package:dinner/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ChatWithUserScreen extends StatefulWidget {
  final String token;
  final String? roomId; // The Chat Room ID
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
  late String userId; // Lưu user_id từ token
  List<Map<String, String>> messages = []; // Stores chat messages
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController(); // Scroll controller
  bool showEmojiPicker = false; // Toggle for emoji keyboard

  @override
  void initState() {
    super.initState();
    print("Initializing ChatWithUserScreen with Room ID: ${widget.roomId}");

    // Decode token để lấy user_id
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    userId = decodedToken['user_id'].toString();
    print("Decoded user_id: $userId");

    if (widget.roomId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid Room ID!")),
        );
        Navigator.pop(context);
      });
    }

    // Fetch stored messages first
    fetchStoredMessages();

    // Initialize WebSocket channel
    channel = WebSocketChannel.connect(
      Uri.parse('ws://10.147.18.78:8000/ws/chat/${widget.roomId}/?token=${widget.token}'),
    );

    // Listen for incoming WebSocket messages
    channel.stream.listen((data) {
      final decodedMessage = json.decode(data);

      setState(() {
        messages.add({
          'sender_id': decodedMessage['sender_id'].toString(),
          'message': decodedMessage['message'],
        });
      });

      // Scroll to the bottom after receiving a message
      scrollToBottom();
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void fetchStoredMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.147.18.78:8000/api/chat/${widget.roomId}/messages/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedMessages = json.decode(response.body);
        setState(() {
          messages = fetchedMessages.map((msg) {
            return {
              'sender_id': msg['sender'].toString(),
              'message': msg['message'].toString(),
            };
          }).toList();
        });

        // Scroll to the bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom();
        });
      } else {
        print("Failed to fetch messages: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      final message = messageController.text.trim();
      print("Sending message: $message");

      // Send the message to the WebSocket server
      channel.sink.add(
        json.encode({
          'message': message,
          'sender_id': userId,
        }),
      );

      // Add the message to the local UI
      setState(() {
        messages.add({
          'sender_id': userId,
          'message': message,
        });
      });

      messageController.clear();

      // Scroll to the bottom after sending a message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    }
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void navigateToUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.147.18.78:8000/api/users/${widget.username}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final userDetails = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(
              username: widget.username,
              profilePicture: widget.profilePicture,
              userDetails: userDetails,
            ),
          ),
        );
      } else {
        print("Failed to fetch user details: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: GestureDetector(
          onTap: navigateToUserProfile, // Điều hướng đến UserProfileScreen
          child: Row(
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
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['sender_id'] == userId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
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
