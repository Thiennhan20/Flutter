import 'package:dinner/profile_user.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'chat_with_user.dart';

class MessagesScreen extends StatefulWidget {
  final String token;

  const MessagesScreen({Key? key, required this.token}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> matchList = [];

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  void fetchMatches() async {
    try {
      final matches = await apiService.fetchMatches(widget.token);
      print("Matches data: $matches"); // In log kiểm tra dữ liệu trả về
      setState(() {
        matchList = matches;
      });
    } catch (e) {
      print('Error fetching matches: $e');
    }
  }


  Widget _buildBottomNavButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 30),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Danh sách người dùng đã match
          Expanded(
            child: matchList.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No matches yet!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            )
                : ListView.builder(
              itemCount: matchList.length,
              itemBuilder: (context, index) {
                final match = matchList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          match['profile_picture'] ?? 'https://via.placeholder.com/150',
                        ),
                      ),
                      title: Text(
                        match['username'] ?? 'Unknown',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        match['bio'] ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        if (match['room_id'] == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Room ID is missing!")),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatWithUserScreen(
                              token: widget.token,
                              roomId: match['room_id'], // Room ID từ API
                              username: match['username'],
                              profilePicture: match['profile_picture'],
                            ),
                          ),
                        );
                      },



                    ),
                  ),
                );
              },
            ),
          ),
          // Navigation Bar dưới cùng (Cố định)
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomNavButton(Icons.home, 'Home', Colors.red, () {
                  Navigator.popUntil(context, (route) => route.isFirst); // Quay về màn hình Home
                }),
                _buildBottomNavButton(Icons.search, 'Search', Colors.blue, () {
                  // Điều hướng đến trang Search
                  print("Search pressed");
                }),
                _buildBottomNavButton(Icons.chat, 'Messages', Colors.green, () {
                  // Đang ở trang Messages
                }),
                _buildBottomNavButton(Icons.person, 'Profile', Colors.purple, () async {
                  try {
                    final user = await ApiService().fetchCurrentUser(widget.token);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileUserScreen(user: user, token: widget.token ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error fetching profile: $e')),
                    );
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
