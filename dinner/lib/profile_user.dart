import 'package:flutter/material.dart';
import 'setting_account.dart';
class ProfileUserScreen extends StatelessWidget {
  final dynamic user;

  const ProfileUserScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Ẩn nút quay lại
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true, // Canh giữa tiêu đề
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
                            onPressed: () {
                              // Logic chỉnh sửa ảnh đại diện
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
                  // Nút hoàn thành
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('100% HOÀN THÀNH'),
                  ),
                  const SizedBox(height: 20),
                  // Các tính năng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeatureCard('0 lượt', Icons.star, 'Siêu Thích', Colors.blue),
                      _buildFeatureCard('0 lượt', Icons.bolt, 'Lượt Tăng Tốc', Colors.purple),
                      _buildFeatureCard('0 gói', Icons.local_fire_department, 'Gói Đăng Ký', Colors.red),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Thẻ nâng cấp
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.yellow[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tinder Gold',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bao gồm các tính năng:',
                          style: TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        _buildFeatureComparison('Xem ai Thích Bạn', true),
                        _buildFeatureComparison('Top Tuyển chọn', true),
                        _buildFeatureComparison('Lượt Siêu Thích Miễn Phí', true),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            // Logic nâng cấp
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Nâng cấp ngay', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
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
                  Navigator.pop(context); // Quay lại màn hình trước đó (Home)
                }),
                _buildBottomNavButton(Icons.search, 'Search', Colors.blue, () {}),
                _buildBottomNavButton(Icons.chat, 'Messages', Colors.green, () {}),
                _buildBottomNavButton(Icons.person, 'Profile', Colors.purple, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String count, IconData icon, String title, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildFeatureComparison(String feature, bool isGold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(feature, style: const TextStyle(color: Colors.black)),
        Icon(
          isGold ? Icons.check : Icons.close,
          color: isGold ? Colors.green : Colors.red,
        ),
      ],
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
