import 'package:flutter/material.dart';
import 'api_service.dart';
import 'profile_user.dart';

class UserListScreen extends StatefulWidget {
  final String token;

  const UserListScreen({super.key, required this.token});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> users;
  List<dynamic> userList = [];

  @override
  void initState() {
    super.initState();
    apiService.fetchUsers(widget.token).then((data) {
      setState(() {
        userList = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dinner'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Nội dung danh sách người dùng
          Expanded(
            child: userList.isNotEmpty
                ? Stack(
              children: [
                Stack(
                  children: userList.asMap().entries.map((entry) {
                    return Dismissible(
                      key: ValueKey(entry.key),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        setState(() {
                          userList.removeAt(entry.key);
                        });

                        if (direction == DismissDirection.startToEnd) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Liked!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (direction == DismissDirection.endToStart) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Disliked!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: ProfileCard(user: entry.value),
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.green,
                        child: const Icon(Icons.favorite, color: Colors.white, size: 36),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(Icons.clear, color: Colors.white, size: 36),
                      ),
                    );
                  }).toList(),
                ),
              ],
            )
                : const Center(
              child: Text(
                'No users left!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Navigation Bar dưới cùng
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomNavButton(Icons.home, 'Home', Colors.red, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserListScreen(token: widget.token)),
                  );
                }),
                _buildBottomNavButton(Icons.search, 'Search', Colors.blue, () {}),
                _buildBottomNavButton(Icons.chat, 'Messages', Colors.green, () {}),
                _buildBottomNavButton(Icons.person, 'Profile', Colors.purple, () async {
                  try {
                    final user = await ApiService().fetchCurrentUser(widget.token);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileUserScreen(user: user),
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

  Widget _buildBottomNavButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return Column(
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
}

class ProfileCard extends StatelessWidget {
  final dynamic user;

  const ProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Hình ảnh hoặc placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: user['profile_picture'] != null
                ? Image.network(
              user['profile_picture'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 1.0,
            )
                : Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(
                  Icons.person,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          // Tên và tuổi
          Positioned(
            left: 20,
            bottom: 20,
            child: Row(
              children: [
                Text(
                  '${user['username'] ?? 'No Name'}, ${user['age'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Trạng thái online/offline
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
