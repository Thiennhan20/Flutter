import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Cài Đặt',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng màn hình cài đặt
            },
            child: const Text(
              'Xong',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Cộng đồng
          _buildSectionTitle('CỘNG ĐỒNG'),
          _buildListTile('Quy tắc Cộng đồng'),
          _buildListTile('Bí quyết An toàn'),
          _buildListTile('Trung tâm An toàn'),

          // Quyền riêng tư
          _buildSectionTitle('QUYỀN RIÊNG TƯ'),
          _buildListTile('Chính sách Cookie'),
          _buildListTile('Chính sách Quyền riêng tư'),
          _buildListTile('Tùy chọn Quyền riêng tư'),

          // Pháp lý
          _buildSectionTitle('PHÁP LÝ'),
          _buildListTile('Giấy phép'),
          _buildListTile('Điều khoản Dịch vụ'),

          // Đăng xuất và phiên bản
          const SizedBox(height: 20),
          ListTile(
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            onTap: () {
              // Xử lý đăng xuất
              _logout(context);
            },
          ),
          const SizedBox(height: 10),
          Column(
            children: const [
              Icon(Icons.local_fire_department, color: Colors.red, size: 30),
              SizedBox(height: 8),
              Text(
                'Phiên bản 15.23.1',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListTile(
            title: const Text(
              'Xóa tài khoản',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            onTap: () {
              // Logic xóa tài khoản
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile(String title) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: () {
        // Logic khi bấm vào từng mục
      },
    );
  }
}
void _logout(BuildContext context) async {
  // Lấy instance của SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Xóa token
  await prefs.remove('access_token'); // Xóa access token
  await prefs.remove('refresh_token'); // Xóa refresh token nếu có

  // Điều hướng về màn hình đăng nhập và xóa lịch sử điều hướng
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
  );
}


