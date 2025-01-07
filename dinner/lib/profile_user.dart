import 'package:flutter/material.dart';
import 'change_information_user.dart';
import 'messages_screen.dart';
import 'setting_account.dart';

class ProfileUserScreen extends StatefulWidget {
  final dynamic user;
  final String token; // Thêm token

  const ProfileUserScreen({Key? key, required this.user, required this.token}) : super(key: key);

  @override
  _ProfileUserScreenState createState() => _ProfileUserScreenState();
}

class _ProfileUserScreenState extends State<ProfileUserScreen> {
  late dynamic user;

  @override
  void initState() {
    super.initState();
    user = widget.user; // Khởi tạo giá trị ban đầu cho user
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar người dùng
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: user['profile_picture'] != null
                            ? NetworkImage(user['profile_picture'])
                            : null,
                        child: user['profile_picture'] == null
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () async {
                              final updatedUser = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangeInformationUserScreen(
                                    user: user,
                                    token: widget.token,
                                  ),
                                ),
                              );

                              if (updatedUser != null) {
                                // Cập nhật thông tin user trong giao diện
                                setState(() {
                                  user['username'] = updatedUser['username'];
                                  user['age'] = updatedUser['age'];
                                  user['location'] = updatedUser['location'];
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tên và tuổi
                  Text(
                    '${user['username'] ?? 'No Name'}, ${user['age'] ?? 'N/A'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      print('Complete profile button clicked');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('100% HOÀN THÀNH'),
                  ),
                ],
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
                  Navigator.popUntil(context, (route) => route.isFirst);
                }),
                _buildBottomNavButton(Icons.search, 'Search', Colors.blue, () {}),
                _buildBottomNavButton(Icons.chat, 'Messages', Colors.green, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagesScreen(token: widget.token), // Truyền token chính xác
                    ),
                  );
                }),
                _buildBottomNavButton(Icons.person, 'Profile', Colors.purple, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

