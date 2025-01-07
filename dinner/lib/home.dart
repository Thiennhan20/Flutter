import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'login_screen.dart';
import 'match_screen.dart';
import 'messages_screen.dart';
import 'profile_user.dart';

class UserListScreen extends StatefulWidget {
  final String token;

  const UserListScreen({super.key, required this.token});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> userList = [];
  String? yourImage; // Lưu ảnh của bạn

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Gọi hàm fetchUsers
    apiService.fetchCurrentUser(widget.token).then((data) {
      setState(() {
        yourImage = data['profile_picture']; // Lưu ảnh của bạn
      });
    });
  }

  void fetchUsers() async {
    try {
      // Lấy danh sách tất cả người dùng
      final users = await apiService.fetchUsers(widget.token);
      // Lấy danh sách các user đã match
      final matches = await apiService.fetchMatches(widget.token);

      // Tạo danh sách ID của các user đã match
      final matchedIds = matches.map((match) => match['id']).toSet();

      setState(() {
        // Lọc danh sách user, chỉ giữ những user chưa match
        userList = users.where((user) => !matchedIds.contains(user['id'])).toList();
      });
    } catch (e) {
      if (e.toString().contains('401')) {
        // Xóa token và chuyển đến màn hình đăng nhập nếu gặp lỗi 401
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        print('Error fetching users or matches: $e');
      }
    }
  }




  void _handleSwipe(int userId, bool isLike, String theirImage, String theirName) async {
    final response = await http.post(
      Uri.parse('http://10.147.18.78:8000/api/swipe/'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({'liked': userId, 'is_like': isLike}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['match'] == true) {
        // Điều hướng đến MatchScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchScreen(
              yourImage: yourImage ?? 'https://via.placeholder.com/150', // Ảnh của bạn
              theirImage: theirImage, // Ảnh của người kia
              theirName: theirName, // Tên của người kia
            ),
          ),
        );
      }
    } else {
      print('Swipe API Error: ${response.body}');
    }
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

                        final user = entry.value;
                        if (direction == DismissDirection.startToEnd) {
                          _handleSwipe(user['id'], true, user['profile_picture'], user['username']); // Lướt phải: thích
                        } else if (direction == DismissDirection.endToStart) {
                          _handleSwipe(user['id'], false, user['profile_picture'], user['username']); // Lướt trái: không thích
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
                _buildBottomNavButton(Icons.home, 'Home', Colors.red, () {}),
                _buildBottomNavButton(Icons.search, 'Search', Colors.blue, () {}),
                _buildBottomNavButton(Icons.chat, 'Messages', Colors.green, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MessagesScreen(token: widget.token)),
                  );
                }),
                _buildBottomNavButton(Icons.person, 'Profile', Colors.purple, () async {
                  try {
                    final user = await ApiService().fetchCurrentUser(widget.token);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileUserScreen(user: user, token: widget.token),
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

class ProfileCard extends StatefulWidget {
  final dynamic user;

  const ProfileCard({super.key, required this.user});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  bool _isInfoVisible = false; // Trạng thái hiển thị bảng thông tin

  void _toggleInfoVisibility() {
    setState(() {
      _isInfoVisible = !_isInfoVisible;
    });
  }
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

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
            child: widget.user['profile_picture'] != null
                ? Image.network(
              widget.user['profile_picture'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 1,
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
          // Tên và nút
          Positioned(
            left: 20,
            bottom: _isInfoVisible ? 300 : 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tên và tuổi
                Row(
                  children: [
                    Text(
                      '${widget.user['username'] ?? 'No Name'}, ${widget.user['age'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 24,
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
                // Nút mũi tên
                GestureDetector(
                  onTap: _toggleInfoVisibility,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 5,
                          ),
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.transparent,
                            ],
                            stops: [0.6, 1.0],
                          ),
                        ),
                      ),
                      Icon(
                        _isInfoVisible ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 24,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bảng thông tin với thiết kế cải tiến
          if (_isInfoVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0) {
                    _toggleInfoVisibility(); // Vuốt xuống để đóng bảng
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: MediaQuery.of(context).size.height * 0.65,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thanh kéo xuống
                      Center(
                        child: GestureDetector(
                          onTap: _toggleInfoVisibility,
                          child: Container(
                            width: 60,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tên và tuổi
                      Text(
                        '${widget.user['username'] ?? 'No Name'}, ${widget.user['age'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 26, // Tăng kích thước chữ
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bio
                      Text(
                        'Bio:',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.user['bio'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 20, // Tăng kích thước chữ
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Vị trí
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.pinkAccent, size: 28),
                          const SizedBox(width: 10),
                          Text(
                            widget.user['location'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Giới tính
                      Row(
                        children: [
                          const Icon(Icons.transgender, color: Colors.blueAccent, size: 28),
                          const SizedBox(width: 10),
                          Text(
                            widget.user['gender'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Một số thông tin khác (thêm nếu cần)
                      Divider(color: Colors.grey[700], thickness: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(Icons.favorite, 'Hobbies', 'Music'),
                          _buildInfoItem(Icons.work, 'Job', 'Developer'),
                          _buildInfoItem(Icons.school, 'Education', 'Bachelor\'s'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

